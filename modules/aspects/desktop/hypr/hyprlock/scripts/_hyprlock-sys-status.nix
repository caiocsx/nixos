{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "hyprlock-sys-status";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.jq
    pkgs.networkmanager
    pkgs.iw
    pkgs.gawk
    pkgs.procps
  ];
  text = ''
    get_layout() {
      local data layout variant
      data=$(hyprctl devices -j 2>/dev/null || true)
      layout=$(echo "$data" | jq -r '.keyboards[] | select(.main==true) | .layout' 2>/dev/null || true)
      variant=$(echo "$data" | jq -r '.keyboards[] | select(.main==true) | .variant' 2>/dev/null || true)

      layout=$(echo "$layout" | tr '[:lower:]' '[:upper:]')
      variant=$(echo "$variant" | tr '[:lower:]' '[:upper:]')

      if [[ -n "$layout" && "$layout" != "null" ]]; then
        if [[ -n "$variant" && "$variant" != "null" ]]; then
          echo "$layout/$variant "
        else
          echo "$layout "
        fi
      else
        echo "UNK "
      fi
    }

    get_network() {
      local status iface signal icon eth_connected
      status="$(nmcli -t -f STATE general 2>/dev/null || true)"

      case "$status" in
        connected)
          eth_connected="$(nmcli -t -f TYPE,STATE device status 2>/dev/null | awk -F: '$1=="ethernet" && $2=="connected" {print "yes"; exit}')"

          if [[ "$eth_connected" == "yes" ]]; then
            echo "󰈀"
          else
            iface="$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null | awk -F: '$2=="wifi" && $3=="connected"{print $1; exit}')"

            if [[ -n "$iface" ]]; then
              signal="$(iw dev "$iface" link 2>/dev/null | awk '/signal:/ {print $2}')"

              case "$signal" in
                -[0-5][0-9]|-6[0-4]) icon="󰤨" ;;
                -6[5-9]|-7[0-4])     icon="󰤥" ;;
                -7[5-9]|-8[0-4])     icon="󰤢" ;;
                -8[5-9]|-9[0-4])     icon="󰤟" ;;
                *)                   icon="󰤯" ;;
              esac

              echo "$icon"
            else
              echo "󰈀"
            fi
          fi
          ;;
        connecting)
          echo "󱍸"
          ;;
        *)
          echo "󰤮"
          ;;
      esac
    }

    get_battery() {
      local BAT_PATH="" status capacity icon

      for path in /sys/class/power_supply/BAT*; do
        if [[ -d "$path" ]]; then
          BAT_PATH="$path"
          break
        fi
      done

      if [[ -z "$BAT_PATH" ]]; then
        return
      fi

      status="$(cat "$BAT_PATH/status" 2>/dev/null || true)"
      capacity="$(cat "$BAT_PATH/capacity" 2>/dev/null || true)"

      case $((capacity / 10)) in
        0) icon="󰂎" ;;
        1) icon="󰁺" ;;
        2) icon="󰁻" ;;
        3) icon="󰁼" ;;
        4) icon="󰁽" ;;
        5) icon="󰁾" ;;
        6) icon="󰁿" ;;
        7) icon="󰂀" ;;
        8) icon="󰂁" ;;
        9) icon="󰂂" ;;
        10) icon="󰁹" ;;
        *) icon="󰁹" ;;
      esac

      case "$status" in
        "Charging")          echo "󰂄 $capacity%" ;;
        "Full")              echo "󰁹 $capacity%" ;;
        *)                   echo "$icon $capacity%" ;;
      esac
    }

    layout_out="$(get_layout)"
    network_out="$(get_network)"
    battery_out="$(get_battery)"

    output="$layout_out    $network_out"
    if [[ -n "$battery_out" ]]; then
      output="$output    $battery_out"
    fi

    echo "$output"
  '';
}
