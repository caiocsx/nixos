{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "colorpicker";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gnused
    pkgs.hyprpicker
    pkgs.jq
    pkgs.libnotify
    pkgs.procps
    pkgs.wl-clipboard
  ];
  text = ''
    readonly STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/colorpicker"
    readonly HISTORY_FILE="$STATE_DIR/colors"
    readonly HISTORY_LIMIT=10
    readonly DEFAULT_COLOR="#ffffff"
    readonly ICON_MAIN="󰸌"
    readonly ICON_DOT="󰝥"
    readonly WAYBAR_SIGNAL="RTMIN+1"

    setup() {
      mkdir -p "$STATE_DIR"
      touch "$HISTORY_FILE"
    }

    print_json() {
      local current_color tooltip color

      current_color=$(head -n 1 "$HISTORY_FILE" || true)
      if ! [[ "$current_color" =~ ^#[0-9a-fA-F]{6}$ ]]; then
        current_color="$DEFAULT_COLOR"
      fi

      printf -v tooltip '<b>History</b>\n\n→ <b>%s</b> <span color="%s">%s</span>' \
        "$current_color" "$current_color" "$ICON_DOT"
      while IFS= read -r color; do
        if [[ "$color" =~ ^#[0-9a-fA-F]{6}$ ]]; then
          printf -v tooltip '%s\n  <b>%s</b> <span color="%s">%s</span>' \
            "$tooltip" "$color" "$color" "$ICON_DOT"
        fi
      done < <(tail -n +2 "$HISTORY_FILE" | head -n 5)

      jq --compact-output --null-input \
        --arg text "<span color='$current_color'>$ICON_MAIN</span>" \
        --arg tooltip "$tooltip" \
        '{ text: $text, tooltip: $tooltip }'
    }

    pick_color() {
      local new_color

      pkill -x hyprpicker 2>/dev/null || true
      new_color=$(hyprpicker -a -f hex -n 2>/dev/null | grep -Eo '^#[0-9a-fA-F]{6}$' || true)
      [ -n "$new_color" ] || return 0

      printf '%s' "$new_color" | wl-copy
      {
        printf '%s\n' "$new_color"
        grep -vFx "$new_color" "$HISTORY_FILE" | head -n $((HISTORY_LIMIT - 1)) || true
      } | sed '/^$/d' > "$HISTORY_FILE.tmp"
      mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"

      notify-send --urgency=low --expire-time=2000 "Color picker" "Copied: $new_color"
      pkill -"$WAYBAR_SIGNAL" waybar || true
    }

    setup
    case "''${1:-}" in
      --json) print_json ;;
      --list) cat "$HISTORY_FILE" ;;
      "") pick_color ;;
      *) echo "Usage: ''${0##*/} [--json|--list]" >&2; exit 1 ;;
    esac
  '';
}
