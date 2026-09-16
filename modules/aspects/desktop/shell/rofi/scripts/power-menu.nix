{ ... }:
{
  den.aspects.power-menu.homeManager =
    {
      config,
      pkgs,
      ui,
      ...
    }:

    let
      themes = import ../themes/_default.nix { inherit config pkgs ui; };

      powerMenu = pkgs.writeShellApplication {
        name = "power-menu";
        runtimeInputs = [
          pkgs.rofi
          pkgs.util-linux
          pkgs.procps
          pkgs.gnugrep
          pkgs.gawk
        ];
        text = ''
          set_icons() {
            declare -gA ACTIONS=(
              [""]="SHUTDOWN"
              [""]="REBOOT"
              ["󰍃"]="LOGOUT"
              ["󰌾"]="LOCK"
              ["󰏤"]="SUSPEND"
              ["󰤄"]="HIBERNATE"
            )
            ORDERED_ICONS=("" "" "󰍃" "󰌾" "󰏤" "󰤄")
            ICON_YES=''
            ICON_NO='󰅙'
          }

          confirm_action() {
            printf "%s\n%s\n" "$ICON_YES" "$ICON_NO" | \
              rofi -dmenu -p "Confirmation" \
                -mesg "Are you sure?" \
                -theme "${themes.confirm}"
          }

          get_system_info() {
            hostname_str=$(hostname)
            current_user=$(whoami)

            UPTIME=$(uptime -p 2>/dev/null | sed 's/^up //' || true)
            if [ -z "$UPTIME" ]; then
              UPTIME=$(uptime | awk -F'up ' '{print $2}' | cut -d',' -f1 | xargs || echo "unknown")
            fi

            LAST_LOGIN=$(last -n 1 "$current_user" 2>/dev/null | grep -v "wtmp" | head -n 1 | awk '{print $4, $5, $6}' | xargs || true)

            if [ -z "$LAST_LOGIN" ]; then
              LAST_LOGIN=$(who -b | awk '{print $3, $4, $5}' | xargs || echo "Unknown")
            fi
          }

          show_menu() {
            local menu_items
            menu_items="$(printf "%s\n" "''${ORDERED_ICONS[@]}")"

            rofi -dmenu -p " $current_user@$hostname_str" \
              -mesg " Last Login: $LAST_LOGIN |  Uptime: $UPTIME" \
              -theme "${themes.powerMenu}" <<<"$menu_items"
          }

          execute_action() {
            local selected_icon="$1"
            local action="''${ACTIONS[$selected_icon]:-}"

            [[ -z "$action" ]] && exit 1

            if [[ "$action" != "LOCK" ]]; then
              local confirmed
              confirmed="$(confirm_action)"
              [[ "''${confirmed// /}" != "''${ICON_YES// /}" ]] && return
            fi

            case "$action" in
              SHUTDOWN) systemctl poweroff ;;
              REBOOT) systemctl reboot ;;
              LOGOUT) hyprctl eval 'hl.dispatch(hl.dsp.exit())' ;;
              LOCK) hyprlock ;;
              SUSPEND) systemctl suspend ;;
              HIBERNATE) systemctl hibernate ;;
            esac
          }

          main() {
            get_system_info
            set_icons

            local selected_icon
            selected_icon="$(show_menu)"
            [[ -n "$selected_icon" ]] && execute_action "$selected_icon"
          }

          main "$@"
        '';
      };
    in
    {
      home.packages = [
        powerMenu
      ];
    };
}
