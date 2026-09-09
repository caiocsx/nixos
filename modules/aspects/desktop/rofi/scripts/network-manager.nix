{ ... }:
{
  den.aspects.network-manager.homeManager =
    {
      config,
      pkgs,
      ui,
      ...
    }:

    let
      themes = import ../themes/_default.nix { inherit config pkgs ui; };

      networkManager = pkgs.writeShellApplication {
        name = "network-manager";
        runtimeInputs = with pkgs; [
          rofi
          networkmanager
          libnotify
          gnugrep
          gawk
          coreutils
          gnused
        ];
        text = ''
          set_constants() {
            readonly LOG_FILE="/tmp/rofi-network-manager.log"
          }

          set_icons() {
            readonly ICON_WIFI=" "
            readonly ICON_ETH="󰈀 "
            readonly ICON_SAVED=" "
            readonly ICON_ACTIVE="󱘖 "
            readonly ICON_TOGGLE="󰐌 "
            readonly ICON_DELETE="󰆴 "
            readonly ICON_EDITOR="󰒓 "

            readonly ICON_YES=" "
            readonly ICON_NO="󰅙 "
            readonly ICON_BACK="󰌍 "
          }

          show_password_prompt() {
            rofi -dmenu -password -theme "${themes.password}" -p "$1"
          }

          show_menu() {
            rofi -dmenu -theme "${themes.listMenu}" -p "$1"
          }

          notify_info() {
            notify-send "Network Manager" "$1" -t "''${2:-3000}"
          }

          execute_and_notify() {
            local ok_msg="$1"
            local err_msg="$2"
            shift 2

            {
              printf '\n[%s] Running:' "$(date '+%F %T')"
              printf ' %q' "$@"
              printf '\n'
            } >>"$LOG_FILE"

            if "$@" >>"$LOG_FILE" 2>&1; then
              notify_info "$ok_msg"
            else
              notify_info "$err_msg"
            fi
          }

          confirm_action() {
            local confirmed
            confirmed=$(printf "%s\n%s\n" "$ICON_YES" "$ICON_NO" | \
              rofi -dmenu -p "Confirmation" \
                -mesg "Are you sure?" \
                -theme "${themes.confirm}")

            [[ "''${confirmed// /}" == "''${ICON_YES// /}" ]]
          }

          connect_saved() {
            local name="$1"
            notify_info "Connecting to $name..." 2000
            execute_and_notify "Successfully connected to $name" "Failed to connect to $name" nmcli connection up id "$name"
          }

          show_available_wifi() {
            notify_info "Scanning for Wi-Fi networks..." 2000
            nmcli device wifi rescan >/dev/null 2>&1 || true

            local raw_list
            raw_list=$(nmcli -t -f SSID,SECURITY,SIGNAL device wifi list | awk -F':' '
              $1 != "" {
                printf "%-25s | Signal: %3s%% | %s\n", $1, $3, $2
              }
            ' | sort -u)

            if [ -z "$raw_list" ]; then
              notify_info "No Wi-Fi networks found in range."
              wifi_menu
              return
            fi

            local back_opt="''${ICON_BACK} Back"
            local choice
            choice=$(echo -e "$back_opt\n$raw_list" | show_menu "Available Wi-Fi")

            [ -z "$choice" ] && return
            [[ "$choice" == "$back_opt" ]] && { wifi_menu; return; }

            local ssid
            ssid=$(echo "$choice" | awk -F' \\| ' '{print $1}' | sed 's/ *$//')
            [ -z "$ssid" ] && return

            if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
              connect_saved "$ssid"
            else
              local password
              if ! password=$(show_password_prompt "Password for $ssid (Leave blank if open)"); then
                return
              fi
              notify_info "Connecting to $ssid..."
              if [ -z "$password" ]; then
                execute_and_notify "Connected to $ssid" "Failed to connect to $ssid" nmcli device wifi connect "$ssid"
              else
                execute_and_notify "Connected to $ssid" "Failed to connect to $ssid (Wrong password?)" nmcli device wifi connect "$ssid" password "$password"
              fi
            fi
          }

          show_saved() {
            local conn_type="$1"
            local parent_menu="$2"
            local saved_list

            saved_list=$(nmcli -t -f NAME,TYPE connection show | awk -F':' -v type="$conn_type" '$2 == type {print $1}')

            if [ -z "$saved_list" ]; then
              notify_info "No saved connections found."
              $parent_menu
              return
            fi

            local back_opt="''${ICON_BACK} Back"
            local choice
            choice=$(echo -e "$back_opt\n$saved_list" | show_menu "Saved Connections")

            [ -z "$choice" ] && return
            [[ "$choice" == "$back_opt" ]] && { $parent_menu; return; }

            connect_saved "$choice"
          }

          show_active() {
            local conn_type="$1"
            local parent_menu="$2"
            local active_list

            active_list=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active | grep ":$conn_type:" | awk -F':' '{print $1 " (" $3 ")"}')

            if [ -z "$active_list" ]; then
              notify_info "No active connections to disconnect."
              $parent_menu
              return
            fi

            local back_opt="''${ICON_BACK} Back"
            local choice
            choice=$(echo -e "$back_opt\n$active_list" | show_menu "Disconnect")

            [ -z "$choice" ] && return
            [[ "$choice" == "$back_opt" ]] && { $parent_menu; return; }

            local name
            name=$(printf '%s\n' "$choice" | sed 's/ (.*)//')

            if confirm_action; then
              execute_and_notify "Disconnected from $name" "Failed to disconnect" nmcli connection down id "$name"
            fi
            $parent_menu
          }

          delete_connection() {
            local conn_type="$1"
            local parent_menu="$2"
            local target_list

            target_list=$(nmcli -t -f NAME,TYPE connection show | awk -F':' -v type="$conn_type" '$2 == type {print $1}')

            if [ -z "$target_list" ]; then
              notify_info "No connections found to delete."
              $parent_menu
              return
            fi

            local back_opt="''${ICON_BACK} Back"
            local target
            target=$(echo -e "$back_opt\n$target_list" | show_menu "Delete Connection")

            [ -z "$target" ] && return
            [[ "$target" == "$back_opt" ]] && { $parent_menu; return; }

            if confirm_action; then
              execute_and_notify "Connection '$target' deleted" "Failed to delete '$target'" nmcli connection delete id "$target"
            fi
            $parent_menu
          }

          wifi_menu() {
            local wifi_state
            wifi_state=$(nmcli radio wifi)

            local options=(
              "''${ICON_WIFI} Available Wi-Fi"
              "''${ICON_SAVED} Saved Networks"
              "''${ICON_ACTIVE} Disconnect Active"
              "''${ICON_TOGGLE} Toggle Wi-Fi: $wifi_state"
              "''${ICON_DELETE} Delete Connection"
              "''${ICON_BACK} Back"
            )

            local choice
            choice=$(printf "%s\n" "''${options[@]}" | show_menu "Wi-Fi Menu")

            case "$choice" in
              "''${ICON_WIFI}"*) show_available_wifi ;;
              "''${ICON_SAVED}"*) show_saved "802-11-wireless" wifi_menu ;;
              "''${ICON_ACTIVE}"*) show_active "802-11-wireless" wifi_menu ;;
              "''${ICON_TOGGLE}"*)
                if [ "$wifi_state" = "enabled" ]; then
                  execute_and_notify "Wi-Fi disabled" "Failed to disable Wi-Fi" nmcli radio wifi off
                else
                  execute_and_notify "Wi-Fi enabled" "Failed to enable Wi-Fi" nmcli radio wifi on
                fi
                wifi_menu
                ;;
              "''${ICON_DELETE}"*) delete_connection "802-11-wireless" wifi_menu ;;
              "''${ICON_BACK}"*) main_menu ;;
            esac
          }

          ethernet_menu() {
            local net_state
            net_state=$(nmcli networking)

            local options=(
              "''${ICON_SAVED} Saved Connections"
              "''${ICON_ACTIVE} Disconnect Active"
              "''${ICON_TOGGLE} Toggle Networking: $net_state"
              "''${ICON_DELETE} Delete Connection"
              "''${ICON_BACK} Back"
            )

            local choice
            choice=$(printf "%s\n" "''${options[@]}" | show_menu "Ethernet Menu")

            case "$choice" in
              "''${ICON_SAVED}"*) show_saved "802-3-ethernet" ethernet_menu ;;
              "''${ICON_ACTIVE}"*) show_active "802-3-ethernet" ethernet_menu ;;
              "''${ICON_TOGGLE}"*)
                if [ "$net_state" = "enabled" ]; then
                  execute_and_notify "Networking disabled" "Failed to disable Networking" nmcli networking off
                else
                  execute_and_notify "Networking enabled" "Failed to enable Networking" nmcli networking on
                fi
                ethernet_menu
                ;;
              "''${ICON_DELETE}"*) delete_connection "802-3-ethernet" ethernet_menu ;;
              "''${ICON_BACK}"*) main_menu ;;
            esac
          }

          launch_editor() {
            notify_info "Opening Advanced GUI Editor..."
            nm-connection-editor >/dev/null 2>&1 &
            disown
          }

          main_menu() {
            local options=(
              "''${ICON_WIFI} Wi-Fi"
              "''${ICON_ETH} Ethernet"
              "''${ICON_EDITOR} Advanced GUI Editor"
            )

            local choice
            choice=$(printf "%s\n" "''${options[@]}" | show_menu "Network")

            case "$choice" in
              "''${ICON_WIFI}"*) wifi_menu ;;
              "''${ICON_ETH}"*) ethernet_menu ;;
              "''${ICON_EDITOR}"*) launch_editor ;;
            esac
          }

          main() {
            set_constants
            set_icons

            case "''${1-}" in
              "")            main_menu ;;
              -w|--wifi)     wifi_menu ;;
              -h|--help)     echo "Usage: ''${0##*/} [ -w/--wifi | -h/--help]";;
              *)             echo "Unknown option: $1" >&2; exit 1 ;;
            esac
          }

          main "$@"
        '';
      };
    in
    {
      home.packages = [
        networkManager
      ];
    };
}
