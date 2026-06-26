{ pkgs, ... }:

let
  opencodeWaybarDaemon = pkgs.writeShellScriptBin "opencode-waybar-daemon" ''
    set -uo pipefail

    log_dir="''${OPENCODE_LOG_DIR:-$HOME/.local/share/opencode/log}"
    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/opencode"
    state_file="$state_dir/waybar-status.json"

    mkdir -p "$state_dir"

    declare -A seen
    declare -A client_state
    declare -A client_session
    declare -A client_step
    declare -A client_directory

    write_state() {
      local open=0
      local busy=0
      local idle=0
      local tooltip=""
      local line=""

      for client in "''${!client_state[@]}"; do
        case "''${client_state[$client]}" in
          busy)
            open=$((open + 1))
            busy=$((busy + 1))
            line="$client  busy"
            if [ -n "''${client_step[$client]:-}" ]; then
              line="$line step ''${client_step[$client]}"
            fi
            ;;
          idle)
            open=$((open + 1))
            idle=$((idle + 1))
            line="$client  idle"
            ;;
          *)
            continue
            ;;
        esac

        if [ -n "''${client_session[$client]:-}" ]; then
          line="$line  ''${client_session[$client]}"
        fi

        if [ -n "$tooltip" ]; then
          tooltip="$tooltip"$'\n'"$line"
        else
          tooltip="$line"
        fi
      done

      local text=""
      local class="empty"
      local summary="opencode: no clients"

      if [ "$open" -gt 0 ]; then
        summary="opencode: $open client"
        [ "$open" -eq 1 ] || summary="$summary"s
        summary="$summary, $busy busy, $idle idle"

        if [ "$busy" -gt 0 ]; then
          text="OC $busy/$open"
          class="busy"
        else
          text="OC $open"
          class="idle"
        fi

        tooltip="$summary"$'\n'"$tooltip"
      else
        tooltip="$summary"
      fi

      ${pkgs.jq}/bin/jq -cn \
        --arg text "$text" \
        --arg tooltip "$tooltip" \
        --arg class "$class" \
        '{text: $text, tooltip: $tooltip, class: $class}' \
        > "$state_file.tmp"
      mv "$state_file.tmp" "$state_file"
    }

    close_client() {
      local client="$1"
      unset "client_state[$client]"
      unset "client_session[$client]"
      unset "client_step[$client]"
      unset "client_directory[$client]"
    }

    opencode_process_for_directory_exists() {
      local directory="$1"
      local proc=""
      local comm=""
      local cwd=""

      [ -n "$directory" ] || return 1

      shopt -s nullglob
      for proc in /proc/[0-9]*; do
        [ -r "$proc/comm" ] || continue
        IFS= read -r comm < "$proc/comm" || continue

        case "$comm" in
          opencode|.opencode*)
            ;;
          *)
            continue
            ;;
        esac

        cwd=$(${pkgs.coreutils}/bin/readlink "$proc/cwd" 2>/dev/null || true)
        if [ "$cwd" = "$directory" ]; then
          shopt -u nullglob
          return 0
        fi
      done
      shopt -u nullglob
      return 1
    }

    close_clients_for_directory_except() {
      local directory="$1"
      local keep_client="$2"
      local client=""

      for client in "''${!client_directory[@]}"; do
        [ "$client" != "$keep_client" ] || continue
        if [ "''${client_directory[$client]}" = "$directory" ]; then
          close_client "$client"
        fi
      done
    }

    bootstrap_running_clients() {
      local proc=""
      local comm=""
      local cwd=""
      local client=""

      shopt -s nullglob
      for proc in /proc/[0-9]*; do
        [ -r "$proc/comm" ] || continue
        IFS= read -r comm < "$proc/comm" || continue

        case "$comm" in
          opencode|.opencode*)
            ;;
          *)
            continue
            ;;
        esac

        cwd=$(${pkgs.coreutils}/bin/readlink "$proc/cwd" 2>/dev/null || true)
        [ -n "$cwd" ] || continue

        client="pid:''${proc##*/}"
        client_state[$client]="idle"
        client_directory[$client]="$cwd"
      done
      shopt -u nullglob
    }

    prune_closed_clients() {
      local client=""
      local directory=""
      local pruned=0

      for client in "''${!client_directory[@]}"; do
        directory="''${client_directory[$client]}"
        if ! opencode_process_for_directory_exists "$directory"; then
          close_client "$client"
          pruned=1
        fi
      done

      [ "$pruned" -eq 1 ]
    }

    handle_line() {
      local client="$1"
      local line="$2"

      if [[ "$line" == *" run="* ]]; then
        local run="''${line#* run=}"
        run="''${run%% *}"
        [ -n "$run" ] && client="$run"
      fi

      local directory=""
      if [[ "$line" == *" directory="* ]]; then
        directory="''${line#* directory=}"
        directory="''${directory%% *}"
      elif [[ "$line" == *" cwd="* ]]; then
        directory="''${line#* cwd=}"
        directory="''${directory%% *}"
      fi

      if [ -n "$directory" ]; then
        if [ -n "$directory" ] && [ "$directory" != "undefined" ] && opencode_process_for_directory_exists "$directory"; then
          close_clients_for_directory_except "$directory" "$client"
          client_directory[$client]="$directory"
        fi
      fi

      if [[ "$line" == *' message="creating instance" '* ]]; then
        client_state[$client]="idle"
        unset "client_step[$client]"
      elif [[ "$line" == *" message=created id=ses_"* ]]; then
        local sid="''${line#* id=}"
        sid="''${sid%% *}"

        client_state[$client]="idle"
        client_session[$client]="$sid"
        unset "client_step[$client]"
      elif [[ "$line" == *" message=loop session.id="* && "$line" == *" step="* ]]; then
        local sid="''${line#* session.id=}"
        sid="''${sid%% *}"
        local step="''${line#* step=}"
        step="''${step%% *}"

        client_state[$client]="busy"
        client_session[$client]="$sid"
        client_step[$client]="$step"
      elif [[ "$line" == *' message="exiting loop" session.id='* ]]; then
        local sid="''${line#* session.id=}"
        sid="''${sid%% *}"

        client_state[$client]="idle"
        client_session[$client]="$sid"
        unset "client_step[$client]"
      elif [[ "$line" == *" message=failed "* && "$line" == *"Failed to init file picker"* ]]; then
        if [ -z "''${client_directory[$client]:-}" ]; then
          close_client "$client"
        fi
      elif [[ "$line" == *"session.updated subscribing"* ]]; then
        client_state[$client]="idle"
      elif [[ "$line" == *"worker shutting down"* ]]; then
        close_client "$client"
      elif [[ "$line" == *"session.updated unsubscribing"* ]]; then
        close_client "$client"
      elif [[ "$line" == *"service=session.prompt"* && "$line" == *"exiting loop"* ]]; then
        :
      elif [[ "$line" == *"session.idle publishing"* ]]; then
        if [ -n "''${client_state[$client]:-}" ]; then
          client_state[$client]="idle"
          unset "client_step[$client]"
        fi
      elif [[ "$line" == *"service=session.prompt"* && "$line" == *"step="* && "$line" == *" loop"* ]]; then
        local sid="''${line#*session.id=}"
        sid="''${sid%% *}"
        local step="''${line#*step=}"
        step="''${step%% *}"

        client_state[$client]="busy"
        client_session[$client]="$sid"
        client_step[$client]="$step"
      fi
    }

    process_file() {
      local file="$1"
      local current="$2"
      local last="''${seen[$file]:-0}"
      local client="''${file##*/}"
      client="''${client%.log}"

      if [ "$current" -le "$last" ]; then
        return
      fi

      while IFS= read -r line; do
        handle_line "$client" "$line"
      done < <(${pkgs.gnused}/bin/sed -n "$((last + 1)),''${current}p" "$file")

      seen[$file]="$current"
    }

    shopt -s nullglob
    for file in "$log_dir"/*.log; do
      [ -f "$file" ] || continue
      seen[$file]=$(${pkgs.coreutils}/bin/wc -l < "$file")
    done
    shopt -u nullglob

    bootstrap_running_clients
    write_state

    while true; do
      changed=0

      shopt -s nullglob
      for file in "$log_dir"/*.log; do
        [ -f "$file" ] || continue
        current=$(${pkgs.coreutils}/bin/wc -l < "$file")
        old="''${seen[$file]:-0}"
        process_file "$file" "$current"
        if [ "$current" -ne "$old" ]; then
          changed=1
        fi
      done
      shopt -u nullglob

      for file in "''${!seen[@]}"; do
        if [ ! -e "$file" ]; then
          client="''${file##*/}"
          client="''${client%.log}"
          close_client "$client"
          unset "seen[$file]"
          changed=1
        fi
      done

      if prune_closed_clients; then
        changed=1
      fi

      if [ "$changed" -eq 1 ]; then
        write_state
        for process in '[.]waybar-wrapped' waybar; do
          ${pkgs.procps}/bin/pkill -x -RTMIN+9 -- "$process" >/dev/null 2>&1 || true
        done
      fi

      sleep 0.2
    done
  '';

  waybarOpencode = pkgs.writeShellScriptBin "waybar-opencode" ''
    state_file="''${XDG_STATE_HOME:-$HOME/.local/state}/opencode/waybar-status.json"

    if [ -s "$state_file" ]; then
      ${pkgs.jq}/bin/jq -c '
        if type == "object" and has("text") and has("class") then
          .
        else
          {text: "", tooltip: "opencode: no clients", class: "empty"}
        end
      ' "$state_file" 2>/dev/null || ${pkgs.jq}/bin/jq -cn '{text: "", tooltip: "opencode: no clients", class: "empty"}'
    else
      ${pkgs.jq}/bin/jq -cn '{text: "", tooltip: "opencode: no clients", class: "empty"}'
    fi
  '';
in

{
  home.packages = [
    opencodeWaybarDaemon
    waybarOpencode
  ];

  systemd.user.services.opencode-waybar = {
    Unit = {
      Description = "opencode Waybar status daemon";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
    };

    Service = {
      ExecStart = "${opencodeWaybarDaemon}/bin/opencode-waybar-daemon";
      Restart = "always";
      RestartSec = 1;
    };

    Install.WantedBy = [ "hyprland-session.target" ];
  };
}
