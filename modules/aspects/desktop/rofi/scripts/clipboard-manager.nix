{ ... }:
{
  den.aspects.clipboard-manager.homeManager =
    {
      config,
      pkgs,
      ui,
      ...
    }:

    let
      themes = import ../themes/_default.nix { inherit config pkgs ui; };

      clipboardManager = pkgs.writeShellApplication {
        name = "clipboard-manager";
        runtimeInputs = with pkgs; [
          rofi
          wl-clipboard
          cliphist
          util-linux
          procps
          gnugrep
          gawk
          libnotify
        ];
        text = ''
          set_constants() {
            readonly FAVORITES_FILE="${config.xdg.cacheHome}/clipboard/clipboard_favorites"
          }

          set_icons() {
            readonly ICON_HISTORY=" "
            readonly ICON_DEL="󰆴 "
            readonly ICON_FAV="󰓎 "
            readonly ICON_MANAGE="󰒓 "
            readonly ICON_CLEAR="󰃢 "
            readonly ICON_ADD="󰐕 "

            readonly ICON_YES=" "
            readonly ICON_NO="󰅙 "
            readonly ICON_BACK="󰌍 "
          }

          show_menu() {
            rofi -dmenu -theme "${themes.listMenu}" -p "$1"
          }

          notify_info() {
            notify-send "Clipboard Manager" "$1" -t "''${2:-3000}"
          }

          confirm_action() {
            local confirmed
            confirmed=$(printf "%s\n%s\n" "$ICON_YES" "$ICON_NO" | \
              rofi -dmenu -p "Confirmation" \
                -mesg "Are you sure?" \
                -theme "${themes.confirm}")

            [[ "''${confirmed// /}" == "''${ICON_YES// /}" ]]
          }

          fav_decode_array() {
            local -n _out=$1
            _out=()
            local line
            while IFS= read -r line; do
              _out+=("$(printf '%s' "$line" | base64 --decode | tr '\n' ' ')")
            done <"$FAVORITES_FILE"
          }

          menu_history() {
            local items
            mapfile -t items < <(cliphist list | sed '/^\s*$/d')
            local total=''${#items[@]}

            if [ "$total" -eq 0 ]; then
              notify_info "Clipboard history is empty."
              main_menu
              return
            fi

            local back_opt="''${ICON_BACK} Back"
            local list=("$back_opt")
            for i in "''${!items[@]}"; do
              local num=$((total - i))
              local snippet="''${items[i]#*$'\t'}"
              list+=("$num. $snippet")
            done

            local selection
            selection=$(printf '%s\n' "''${list[@]}" | show_menu "Copy History")

            [ -z "$selection" ] && return
            [[ "$selection" == "$back_opt" ]] && { main_menu; return; }

            while IFS= read -r sel; do
              local num
              num=$(awk -F'.' '{print $1}' <<<"$sel")
              if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$total" ]; then
                local idx=$((total - num))
                printf "%s\n" "''${items[$idx]}" | cliphist decode
              fi
            done <<<"$selection" | wl-copy

            notify_info "Copied to clipboard."
          }

          menu_delete_items() {
            local items
            mapfile -t items < <(cliphist list | sed '/^\s*$/d')
            local total=''${#items[@]}

            if [ "$total" -eq 0 ]; then
              notify_info "Clipboard history is empty."
              main_menu
              return
            fi

            local back_opt="''${ICON_BACK} Back"
            local list=("$back_opt")
            for i in "''${!items[@]}"; do
              local num=$((total - i))
              local snippet="''${items[i]#*$'\t'}"
              list+=("$num. $snippet")
            done

            local selection
            selection=$(printf '%s\n' "''${list[@]}" | show_menu "Delete Items")

            [ -z "$selection" ] && return
            [[ "$selection" == "$back_opt" ]] && { main_menu; return; }

            while IFS= read -r sel; do
              local num
              num=$(awk -F'.' '{print $1}' <<<"$sel")
              if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$total" ]; then
                local idx=$((total - num))
                cliphist delete <<<"''${items[$idx]}"
              fi
            done <<<"$selection"

            notify_info "Item(s) deleted."
            menu_delete_items
          }

          menu_clear_history() {
            if confirm_action; then
              cliphist wipe
              notify_info "Clipboard history cleared."
            fi
            main_menu
          }

          menu_view_favorites() {
            if [ ! -s "$FAVORITES_FILE" ]; then
              notify_info "No favorites saved."
              main_menu
              return
            fi

            local favs decoded
            mapfile -t favs <"$FAVORITES_FILE"
            fav_decode_array decoded
            local total=''${#decoded[@]}

            local back_opt="''${ICON_BACK} Back"
            local list=("$back_opt")

            for (( i=total-1; i>=0; i-- )); do
              local num=$((i + 1))
              list+=("$num. ''${decoded[i]}")
            done

            local selection
            selection=$(printf '%s\n' "''${list[@]}" | show_menu "Favorites")

            [ -z "$selection" ] && return
            [[ "$selection" == "$back_opt" ]] && { main_menu; return; }

            local num
            num=$(awk -F'.' '{print $1}' <<<"$selection")

            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$total" ]; then
              local idx=$((num - 1))
              echo "''${favs[$idx]}" | base64 --decode | wl-copy
              notify_info "Favorite copied to clipboard."
            else
              notify_info "Invalid selection."
            fi
          }

          menu_add_favorite() {
            mkdir -p "$(dirname "$FAVORITES_FILE")"

            local items
            mapfile -t items < <(cliphist list | sed '/^\s*$/d')
            local total=''${#items[@]}

            if [ "$total" -eq 0 ]; then
              notify_info "No history items to favorite."
              manage_favorites_menu
              return
            fi

            local back_opt="''${ICON_BACK} Back"
            local list=("$back_opt")
            for i in "''${!items[@]}"; do
              local num=$((total - i))
              local snippet="''${items[i]#*$'\t'}"
              list+=("$num. $snippet")
            done

            local selection
            selection=$(printf '%s\n' "''${list[@]}" | show_menu "Add to Favorites")

            [ -z "$selection" ] && return
            [[ "$selection" == "$back_opt" ]] && { manage_favorites_menu; return; }

            local num
            num=$(awk -F'.' '{print $1}' <<<"$selection")

            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$total" ]; then
              local idx=$((total - num))
              local orig_item="''${items[$idx]}"

              local decoded
              if ! decoded=$(printf '%s\n' "$orig_item" | cliphist decode); then
                notify_info "Failed to decode history item."
                manage_favorites_menu
                return
              fi

              if [ -z "$decoded" ]; then
                notify_info "Decoded content is empty."
                manage_favorites_menu
                return
              fi

              local encoded
              encoded=$(printf "%s" "$decoded" | base64 -w0)

              if ! grep -Fxq "$encoded" "$FAVORITES_FILE" 2>/dev/null; then
                printf '%s\n' "$encoded" >>"$FAVORITES_FILE"
                notify_info "Added to favorites."
              else
                notify_info "Item is already a favorite."
              fi
            else
              notify_info "Invalid selection."
            fi

            manage_favorites_menu
          }

          menu_delete_favorite() {
            if [ ! -s "$FAVORITES_FILE" ]; then
              notify_info "No favorites to delete."
              manage_favorites_menu
              return
            fi

            local favs decoded
            mapfile -t favs <"$FAVORITES_FILE"
            fav_decode_array decoded
            local total=''${#decoded[@]}

            local back_opt="''${ICON_BACK} Back"
            local list=("$back_opt")

            for (( i=total-1; i>=0; i-- )); do
              local num=$((i + 1))
              list+=("$num. ''${decoded[i]}")
            done

            local selection
            selection=$(printf '%s\n' "''${list[@]}" | show_menu "Delete Favorite")

            [ -z "$selection" ] && return
            [[ "$selection" == "$back_opt" ]] && { manage_favorites_menu; return; }

            local num
            num=$(awk -F'.' '{print $1}' <<<"$selection")

            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$total" ]; then
              sed -i "''${num}d" "$FAVORITES_FILE"
              notify_info "Removed favorite."
            else
              notify_info "Invalid selection."
            fi

            manage_favorites_menu
          }

          menu_clear_favorites() {
            if confirm_action; then
              : >"$FAVORITES_FILE"
              notify_info "Favorites cleared."
            fi
            manage_favorites_menu
          }

          manage_favorites_menu() {
            local options=(
              "''${ICON_ADD} Add from History"
              "''${ICON_DEL} Delete Favorite"
              "''${ICON_CLEAR} Clear Favorites"
              "''${ICON_BACK} Back"
            )

            local choice
            choice=$(printf "%s\n" "''${options[@]}" | show_menu "Manage Favorites")

            case "$choice" in
              "''${ICON_ADD}"*) menu_add_favorite ;;
              "''${ICON_DEL}"*) menu_delete_favorite ;;
              "''${ICON_CLEAR}"*) menu_clear_favorites ;;
              "''${ICON_BACK}"*) main_menu ;;
            esac
          }

          main_menu() {
            local options=(
              "''${ICON_HISTORY} Clipboard History"
              "''${ICON_FAV} View Favorites"
              "''${ICON_MANAGE} Manage Favorites"
              "''${ICON_DEL} Delete Items"
              "''${ICON_CLEAR} Clear History"
            )

            local choice
            choice=$(printf "%s\n" "''${options[@]}" | show_menu "Clipboard")

            case "$choice" in
              "''${ICON_HISTORY}"*) menu_history ;;
              "''${ICON_FAV}"*) menu_view_favorites ;;
              "''${ICON_MANAGE}"*) manage_favorites_menu ;;
              "''${ICON_DEL}"*) menu_delete_items ;;
              "''${ICON_CLEAR}"*) menu_clear_history ;;
            esac
          }

          main() {
            set_constants
            set_icons

            case "''${1:-}" in
              "")            main_menu ;;
              -H|--history)  menu_history ;;
              -f|--favorites) menu_view_favorites ;;
              -m|--manage)   manage_favorites_menu ;;
              -d|--delete)   menu_delete_items ;;
              -w|--wipe)     menu_clear_history ;;
              -h|--help)     echo "Usage: ''${0##*/} [ -H/--history | -f/--favorites | -m/--manage | -d/--delete | -w/--wipe | -h/--help ]" ;;
              *)             echo "Unknown option: $1" >&2; exit 1 ;;
            esac
          }

          main "$@"
        '';
      };
    in
    {
      home.packages = [
        clipboardManager
      ];
    };
}
