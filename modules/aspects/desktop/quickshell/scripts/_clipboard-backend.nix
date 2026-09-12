{ config, pkgs }:
pkgs.writeShellApplication {
  name = "quickshell-clipboard-backend";
  runtimeInputs = [
    pkgs.cliphist
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.jq
    pkgs.util-linux
    pkgs.wl-clipboard
  ];
  text = ''
    readonly FAVORITES_FILE="${config.xdg.cacheHome}/clipboard/clipboard_favorites"

    ensure_favorites_file() {
      mkdir -p "$(dirname "$FAVORITES_FILE")"
      touch "$FAVORITES_FILE"
    }

    list_history() {
      cliphist list | jq -Rsc '
        split("\n")
        | map(select(length > 0))
        | map(
            . as $raw
            | ($raw | index("\t")) as $tab
            | {
                id: $raw[0:$tab],
                text: $raw[($tab + 1):],
                token: ($raw | @base64)
              }
          )
      '
    }

    list_favorites() {
      ensure_favorites_file

      while IFS= read -r encoded; do
        [[ -n "$encoded" ]] || continue

        decoded="$(printf '%s' "$encoded" | base64 --decode 2>/dev/null | tr '\n' ' ')" || continue
        jq -cn --arg text "$decoded" --arg token "$encoded" '{ text: $text, token: $token }'
      done <"$FAVORITES_FILE" | jq -s '.'
    }

    copy_history() {
      printf '%s\t' "$1" | cliphist decode | wl-copy
    }

    copy_favorite() {
      printf '%s' "$1" | base64 --decode | wl-copy
    }

    add_favorite() {
      ensure_favorites_file

      encoded="$(printf '%s\t' "$1" | cliphist decode | base64 -w0)"
      [[ -n "$encoded" ]] || exit 1

      exec 9>>"$FAVORITES_FILE"
      flock 9
      grep -Fxq -- "$encoded" "$FAVORITES_FILE" || printf '%s\n' "$encoded" >&9
    }

    remove_history() {
      printf '%s' "$1" | base64 --decode | cliphist delete
    }

    remove_favorite() {
      ensure_favorites_file

      temporary_file="$(mktemp "''${FAVORITES_FILE}.XXXXXX")"
      trap 'rm -f "$temporary_file"' EXIT
      grep -Fvx -- "$1" "$FAVORITES_FILE" >"$temporary_file" || true
      mv "$temporary_file" "$FAVORITES_FILE"
      trap - EXIT
    }

    clear_favorites() {
      ensure_favorites_file
      : >"$FAVORITES_FILE"
    }

    case "''${1-}" in
      --history)          list_history ;;
      --favorites)        list_favorites ;;
      --copy-history)     copy_history "''${2:?Missing cliphist id}" ;;
      --copy-favorite)    copy_favorite "''${2:?Missing favorite token}" ;;
      --add-favorite)     add_favorite "''${2:?Missing cliphist id}" ;;
      --remove-history)   remove_history "''${2:?Missing history token}" ;;
      --remove-favorite)  remove_favorite "''${2:?Missing favorite token}" ;;
      --clear-history)    cliphist wipe ;;
      --clear-favorites)  clear_favorites ;;
      -h|--help)
        echo "Usage: ''${0##*/} [--history | --favorites | --copy-history ID | --copy-favorite TOKEN | --add-favorite ID | --remove-history TOKEN | --remove-favorite TOKEN | --clear-history | --clear-favorites]"
        ;;
      *)
        echo "Unknown option: ''${1-}" >&2
        exit 1
        ;;
    esac
  '';
}
