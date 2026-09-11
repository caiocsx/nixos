{ ... }:
{
  den.aspects.wallpaper-picker.homeManager =
    {
      config,
      pkgs,
      ui,
      ...
    }:

    let
      themes = import ../themes/_default.nix { inherit config pkgs ui; };

      wallpaperPicker = pkgs.writeShellApplication {
        name = "wallpaper-picker";
        runtimeInputs = [
          pkgs.rofi
          pkgs.awww
          pkgs.libnotify
          pkgs.imagemagick
          pkgs.coreutils
          pkgs.findutils
          pkgs.gawk
        ];
        text = ''
          set_constants() {
            readonly WALLPAPERS_DIR="${config.home.homeDirectory}/Pictures/Wallpapers"
            readonly CACHE_DIR="${config.xdg.cacheHome}"
            readonly WALLPAPERS_CACHE_DIR="$CACHE_DIR/wallpapers"
            readonly THUMB_DIR="$WALLPAPERS_CACHE_DIR/thumbs"
            readonly CURRENT_WALLPAPER="$WALLPAPERS_CACHE_DIR/current"
            readonly LOCKSCREEN_WALLPAPER="$WALLPAPERS_CACHE_DIR/lockscreen"
          }

          setup() {
            mkdir -p "$WALLPAPERS_CACHE_DIR" "$THUMB_DIR"
          }

          notify_info() {
            local msg="$1"
            local sub_msg="''${2:-}"
            local icon="''${3:-}"

            if [ -n "$icon" ] && [ -f "$icon" ]; then
              notify-send -a "Wallpaper Picker" -i "$icon" -u low "$msg" "$sub_msg"
            else
              notify-send "Wallpaper Picker" "$msg" -t 3000
            fi
          }

          ensure_symlink() {
            local target="$1" link="$2"
            mkdir -p "$(dirname "$link")"
            ln -sfn "$target" "$link"
          }

          init_wallpapers() {
            mapfile -d "" -t WALLPAPER_LIST < <(
              find -L "$WALLPAPERS_DIR" -type f \
                \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) \
                -print0 | sort -z
            )

            if [ "''${#WALLPAPER_LIST[@]}" -eq 0 ]; then
              notify_info "No wallpapers found" "Directory: $WALLPAPERS_DIR"
              exit 1
            fi
          }

          get_thumbnail_key() {
            printf '%s' "$1" | sha256sum | awk '{print $1}'
          }

          get_thumbnail_path() {
            local wallpaper_path="$1"
            local wallpaper_key
            wallpaper_key=$(get_thumbnail_key "$wallpaper_path")
            printf '%s/%s.png' "$THUMB_DIR" "$wallpaper_key"
          }

          ensure_thumbnail() {
            local source_path="$1" thumbnail_path="$2"
            [ -s "$thumbnail_path" ] && return 0

            local target="''${source_path}"
            [[ "$source_path" =~ \.(gif|GIF)$ ]] && target="''${source_path}[0]"

            magick "$target" -auto-orient -thumbnail "512x512^" -gravity center -extent "512x512" -strip "$thumbnail_path" 2>/dev/null || {
              rm -f "$thumbnail_path"
              return 1
            }
            return 0
          }

          prewarm_thumbnails() {
            local max_jobs=4 active_jobs=0
            local wallpaper_path thumbnail_path

            for wallpaper_path in "''${WALLPAPER_LIST[@]}"; do
              thumbnail_path=$(get_thumbnail_path "$wallpaper_path")
              [ -s "$thumbnail_path" ] && continue

              ( ensure_thumbnail "$wallpaper_path" "$thumbnail_path" >/dev/null 2>&1 || true ) &

              active_jobs=$((active_jobs + 1))
              if [ "$active_jobs" -ge "$max_jobs" ]; then
                wait -n || true
                active_jobs=$((active_jobs - 1))
              fi
            done

            wait
          }

          create_lockscreen_wallpaper() {
            local wallpaper_path="$1"
            local lockscreen_source

            if [[ "$wallpaper_path" =~ \.(gif|GIF)$ ]]; then
              local wallpaper_key lockscreen_file
              wallpaper_key=$(get_thumbnail_key "$wallpaper_path")
              lockscreen_file="$WALLPAPERS_CACHE_DIR/lockscreen-$wallpaper_key.png"

              if [ ! -s "$lockscreen_file" ]; then
                magick "''${wallpaper_path}[0]" -auto-orient -strip "$lockscreen_file" 2>/dev/null || {
                  rm -f "$lockscreen_file"
                  echo "Failed to generate lockscreen wallpaper from GIF: $wallpaper_path" >&2
                  return 1
                }
              fi
              lockscreen_source="$lockscreen_file"
            else
              lockscreen_source="$wallpaper_path"
            fi

            ensure_symlink "$lockscreen_source" "$LOCKSCREEN_WALLPAPER"
          }

          set_wall() {
            local wallpaper_path="$1"
            local current_wallpaper

            if [ ! -f "$wallpaper_path" ]; then
              notify_info "Error" "File not found: $wallpaper_path"
              return 1
            fi

            current_wallpaper=$(readlink -f "$CURRENT_WALLPAPER" 2>/dev/null || true)
            if [ "$current_wallpaper" != "$wallpaper_path" ]; then
              ensure_symlink "$wallpaper_path" "$CURRENT_WALLPAPER"
            fi

            create_lockscreen_wallpaper "$wallpaper_path"

            awww img "$wallpaper_path" --transition-type any --transition-fps 60 --transition-duration 0.5
          }

          get_current_index() {
            local current_wallpaper
            current_wallpaper=$(readlink -f "$CURRENT_WALLPAPER" 2>/dev/null || true)

            for i in "''${!WALLPAPER_LIST[@]}"; do
              if [ "$(readlink -f "''${WALLPAPER_LIST[$i]}" 2>/dev/null || true)" = "$current_wallpaper" ]; then
                printf '%s\n' "$i"
                return 0
              fi
            done
            printf '0\n'
          }

          next_wall() {
            init_wallpapers
            local index
            index=$(get_current_index)
            set_wall "''${WALLPAPER_LIST[$(((index + 1) % ''${#WALLPAPER_LIST[@]}))]}"
          }

          prev_wall() {
            init_wallpapers
            local index
            index=$(get_current_index)
            set_wall "''${WALLPAPER_LIST[$(((index - 1 + ''${#WALLPAPER_LIST[@]}) % ''${#WALLPAPER_LIST[@]}))]}"
          }

          random_wall() {
            init_wallpapers
            local current_wallpaper next_wallpaper index
            current_wallpaper=$(readlink -f "$CURRENT_WALLPAPER" 2>/dev/null || true)

            if [ "''${#WALLPAPER_LIST[@]}" -le 1 ]; then
              set_wall "''${WALLPAPER_LIST[0]}"
              return 0
            fi

            while :; do
              index=$((RANDOM % ''${#WALLPAPER_LIST[@]}))
              next_wallpaper="''${WALLPAPER_LIST[$index]}"
              [ "$next_wallpaper" != "$current_wallpaper" ] && break
            done

            set_wall "$next_wallpaper"
          }

          menu_select_wall() {
            init_wallpapers

            local missing_count=0
            for wallpaper in "''${WALLPAPER_LIST[@]}"; do
              if [ ! -s "$(get_thumbnail_path "$wallpaper")" ]; then
                missing_count=$((missing_count + 1))
              fi
            done

            if [ "$missing_count" -gt 0 ]; then
              notify_info "Generating thumbnails" "Generating thumbnails for $missing_count new image(s). Please wait..."
              prewarm_thumbnails
            fi

            local rofi_input_file
            rofi_input_file=$(mktemp)
            trap 'rm -f "'"$rofi_input_file"'"' EXIT

            for wallpaper in "''${WALLPAPER_LIST[@]}"; do
              local w_name w_thumb w_icon
              w_name=$(basename "$wallpaper")
              w_thumb=$(get_thumbnail_path "$wallpaper")
              [ -s "$w_thumb" ] && w_icon="$w_thumb" || w_icon=""

              printf '%s:::%s:::%s\0icon\x1f%s\n' "$w_name" "$wallpaper" "$w_thumb" "$w_icon"
            done > "$rofi_input_file"

            local rofi_output
            rofi_output=$(rofi -dmenu \
              -display-column-separator ":::" -display-columns 1 \
              -i -theme "${themes.wallpaperPicker}" <"$rofi_input_file")

            [ -z "$rofi_output" ] && return 1

            local selected_path
            selected_path=$(awk -F ':::' '{print $2}' <<<"$rofi_output")

            if [ -n "$selected_path" ] && [ -f "$selected_path" ]; then
              set_wall "$selected_path"
              return 0
            else
              notify_info "Error" "Selected file does not exist."
              exit 1
            fi
          }

          main() {
            set_constants
            setup

            case "''${1-}" in
              "")            menu_select_wall ;;
              -n|--next)     next_wall ;;
              -p|--prev)     prev_wall ;;
              -r|--random)   random_wall ;;
              -s|--set)      set_wall "''${2:?Error: Please provide a wallpaper file path}" ;;
              -c|--current)  readlink -f "$CURRENT_WALLPAPER" ;;
              -h|--help)     echo "Usage: ''${0##*/} [ -n/--next | -p/--prev | -r/--random | -s/--set <wallpaper> | -c/--current | -h/--help ]" ;;
              *)             echo "Unknown option: $1" >&2; exit 1 ;;
            esac
          }

          main "$@"
        '';
      };
    in
    {
      home.packages = [
        wallpaperPicker
      ];
    };
}
