{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mako

    (writeShellScriptBin "waybar-focus" ''
      set -u

      signal_waybar() {
        for process in '[.]waybar-wrapped' waybar; do
          ${procps}/bin/pkill -x -RTMIN+10 -- "$process" || true
        done
      }

      get_modes() {
        ${mako}/bin/makoctl mode 2>/dev/null
      }

      focus_enabled() {
        modes="$1"

        while IFS= read -r mode; do
          [ "$mode" = "do-not-disturb" ] && return 0
        done <<< "$modes"

        return 1
      }

      print_status() {
        if ! modes="$(get_modes)"; then
          ${jq}/bin/jq -cn \
            --arg text "󰂚" \
            --arg class "offline" \
            --arg tooltip "Notifications unavailable" \
            '{text: $text, class: $class, tooltip: $tooltip}'
          exit 0
        fi

        if focus_enabled "$modes"; then
          ${jq}/bin/jq -cn \
            --arg text "󰂛" \
            --arg class "enabled" \
            --arg tooltip "Focus mode is on"$'\n'"Notifications are hidden"$'\n'"Click to allow notifications" \
            '{text: $text, class: $class, tooltip: $tooltip}'
        else
          ${jq}/bin/jq -cn \
            --arg text "󰂚" \
            --arg class "disabled" \
            --arg tooltip "Notifications are on"$'\n'"Click to hide notifications" \
            '{text: $text, class: $class, tooltip: $tooltip}'
        fi
      }

      case "''${1:-status}" in
        toggle)
          modes="$(get_modes || true)"

          if focus_enabled "$modes"; then
            ${mako}/bin/makoctl mode -r do-not-disturb >/dev/null 2>&1 || true
          else
            ${mako}/bin/makoctl mode -a do-not-disturb >/dev/null 2>&1 || true
          fi

          signal_waybar
          print_status
          ;;
        on)
          ${mako}/bin/makoctl mode -a do-not-disturb >/dev/null 2>&1 || true
          signal_waybar
          print_status
          ;;
        off)
          ${mako}/bin/makoctl mode -r do-not-disturb >/dev/null 2>&1 || true
          signal_waybar
          print_status
          ;;
        status|*)
          print_status
          ;;
      esac
    '')
  ];
}
