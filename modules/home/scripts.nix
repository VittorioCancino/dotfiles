{ pkgs, inputs, ... }:

let
  hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
in
{
  home.packages = with pkgs; [
    (writeShellScriptBin "toggle-mic" ''
      wpctl set-source-mute @DEFAULT_SOURCE@ toggle
      if brightnessctl --device='platform::micmute' info >/dev/null 2>&1; then
        led=$(brightnessctl --device='platform::micmute' get)
        brightnessctl --device='platform::micmute' set $((1 - led))
      fi
    '')

    (writeShellScriptBin "toggle-mute" ''
      wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      if brightnessctl --device='platform::mute' info >/dev/null 2>&1; then
        led=$(brightnessctl --device='platform::mute' get)
        brightnessctl --device='platform::mute' set $((1 - led))
      fi
    '')

    (writeShellScriptBin "terminal-here" ''
      active_pid="$(${hyprland}/bin/hyprctl activewindow -j | ${jq}/bin/jq -r '.pid // empty')"

      if [ -z "$active_pid" ] || [ "$active_pid" = "0" ]; then
        exec ${alacritty}/bin/alacritty
      fi

      deepest_cwd_pid() {
        pid="$1"
        [ -e "/proc/$pid/cwd" ] || return 0

        candidate="$pid"

        children="$(${procps}/bin/pgrep -P "$pid" 2>/dev/null || true)"
        for child in $children; do
          descendant="$(deepest_cwd_pid "$child")"
          if [ -n "$descendant" ]; then
            candidate="$descendant"
          fi
        done

        printf '%s\n' "$candidate"
      }

      cwd_pid="$(deepest_cwd_pid "$active_pid")"
      cwd="$(${coreutils}/bin/readlink -f "/proc/$cwd_pid/cwd" 2>/dev/null || true)"

      if [ -z "$cwd" ] || [ ! -d "$cwd" ]; then
        cwd="$HOME"
      fi

      exec ${alacritty}/bin/alacritty --working-directory "$cwd"
    '')
  ];
}
