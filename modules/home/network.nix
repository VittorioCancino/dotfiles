{ pkgs, ... }:

{
  home.packages = with pkgs; [
    iw
    (writeShellScriptBin "waybar-network" ''
      PRIMARY=""
      TOOLTIP=""

      ETH_TEXT=""
      WIFI_TEXT=""

      while IFS= read -r line; do
        iface=$(echo "$line" | awk '{print $1}')
        state=$(echo "$line" | awk '{print $2}')
        ip=$(echo "$line" | awk '{print $3}' | cut -d/ -f1)

        [ "$state" = "DOWN" ] && continue
        [ "$iface" = "lo" ]   && continue
        [ -z "$ip" ]          && continue

        case "$iface" in
          wl*)
            ssid=$(iw dev "$iface" link 2>/dev/null | awk '/SSID/{print $2}')
            [ -n "$ssid" ] && WIFI_TEXT="󰤨 $ssid" || WIFI_TEXT="󰤨 wifi"
            TOOLTIP="$TOOLTIP󰤨 $ssid  $ip\n"
            ;;
          *)
            ETH_TEXT="󰈀 wired"
            TOOLTIP="$TOOLTIP󰈀 wired  $ip\n"
            ;;
        esac
      done < <(ip -br addr)

      # Ethernet takes priority on the bar
      if [ -n "$ETH_TEXT" ]; then
        PRIMARY="$ETH_TEXT"
      elif [ -n "$WIFI_TEXT" ]; then
        PRIMARY="$WIFI_TEXT"
      else
        PRIMARY="󰤭"
        TOOLTIP="disconnected"
      fi

      TOOLTIP="''${TOOLTIP%\\n}"
      printf '{"text":"%s","tooltip":"%s"}\n' "$PRIMARY" "$TOOLTIP"
    '')
  ];
}

