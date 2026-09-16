{ ... }:
{
  den.aspects.clipboard.homeManager =
    {
      config,
      pkgs,
      ui,
      ...
    }:

    let
      themes = import ../themes/_default.nix { inherit config pkgs ui; };

      clipboard = pkgs.writeShellApplication {
        name = "clipboard";
        runtimeInputs = [
          pkgs.rofi
          pkgs.wl-clipboard
          pkgs.cliphist
          pkgs.gnused
          pkgs.libnotify
        ];
        text = ''
          readonly ICON_YES=" "
          readonly ICON_NO="󰅙 "

          show_menu() {
            local prompt="$1"
            shift
            rofi -dmenu -theme "${themes.listMenu}" -p "$prompt" "$@"
          }

          notify_info() {
            notify-send "Clipboard" "$1" -t "''${2:-3000}"
          }

          confirm_action() {
            local message="$1"
            local confirmed

            confirmed=$(printf "%s\n%s\n" "$ICON_YES" "$ICON_NO" | \
              rofi -dmenu \
                -mesg "$message" \
                -theme "${themes.confirm}") || return 1

            [[ "''${confirmed// /}" == "''${ICON_YES// /}" ]]
          }

          menu_clear_history() {
            if confirm_action "Clear clipboard history?"; then
              cliphist wipe
              notify_info "Clipboard history cleared."
            fi
          }

          main_menu() {
            local items
            mapfile -t items < <(cliphist list | sed '/^[[:space:]]*$/d')

            if [ "''${#items[@]}" -eq 0 ]; then
              notify_info "Clipboard history is empty."
              return
            fi

            local display_items=()
            local item
            for item in "''${items[@]}"; do
              display_items+=("''${item#*$'\t'}")
            done

            local idx
            idx=$(printf '%s\n' "''${display_items[@]}" | show_menu "Clipboard" -format i) || return

            [ -z "$idx" ] && return

            if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -lt "''${#items[@]}" ]; then
              printf "%s\n" "''${items[$idx]}" | cliphist decode | wl-copy
              notify_info "Copied to clipboard."
            fi
          }

          main() {
            case "''${1:-}" in
              "")            main_menu ;;
              -w|--wipe)     menu_clear_history ;;
              -h|--help)     echo "Usage: ''${0##*/} [ -w/--wipe | -h/--help ]" ;;
              *)             echo "Unknown option: $1" >&2; exit 1 ;;
            esac
          }

          main "$@"
        '';
      };
    in
    {
      home.packages = [
        clipboard
      ];
    };
}
