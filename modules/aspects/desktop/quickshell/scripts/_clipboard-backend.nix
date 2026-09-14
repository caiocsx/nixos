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
    readonly METADATA_FILE="${config.xdg.cacheHome}/clipboard/history_metadata"

    ensure_favorites_file() {
      mkdir -p "$(dirname "$FAVORITES_FILE")"
      touch "$FAVORITES_FILE"
      touch "$METADATA_FILE"
    }

    list_history() {
      ensure_favorites_file

      cliphist list | jq -Rsc \
        --rawfile favorite_lines "$FAVORITES_FILE" \
        --rawfile metadata_lines "$METADATA_FILE" '
        def rows($input):
          $input | split("\n") | map(select(length > 0) | split("\t"));

        (reduce rows($favorite_lines)[] as $row ({ ids: {}, hashes: {} };
          if ($row | length) == 4 then
            .ids[$row[1]] = $row[3] | .hashes[$row[2]] = $row[3]
          elif ($row | length) == 3 and $row[1] != "" then
            .ids[$row[1]] = $row[2]
          else . end
        )) as $favorites
        | (reduce rows($metadata_lines)[] as $row ({};
          if ($row | length) >= 2 then
            .[$row[0]] = {
              timestamp: ($row[1] | tonumber),
              hash: (if ($row | length) >= 3 then $row[2] else "" end)
            }
          else . end
        )) as $metadata
        |
        split("\n")
        | map(select(length > 0))
        | map(
            . as $raw
            | ($raw | index("\t")) as $tab
            | ($raw[0:$tab]) as $id
            | ($metadata[$id].hash // "") as $hash
            | {
                id: $id,
                text: $raw[($tab + 1):],
                token: ($raw | @base64),
                timestamp: ($metadata[$id].timestamp // 0),
                favorite: ($favorites.ids[$id] != null or $favorites.hashes[$hash] != null),
                favoriteToken: ($favorites.ids[$id] // $favorites.hashes[$hash] // "")
              }
          )
      '
    }

    list_favorites() {
      ensure_favorites_file

      while IFS= read -r line; do
        [[ -n "$line" ]] || continue

        if [[ "$line" == *$'\t'*$'\t'*$'\t'* ]]; then
          timestamp="''${line%%$'\t'*}"
          encoded="''${line##*$'\t'}"
        elif [[ "$line" == *$'\t'*$'\t'* ]]; then
          timestamp="''${line%%$'\t'*}"
          encoded="''${line##*$'\t'}"
        else
          timestamp=0
          encoded="$line"
        fi

        decoded="$(printf '%s' "$encoded" | base64 --decode 2>/dev/null | tr '\n' ' ')" || continue
        jq -cn \
          --arg text "$decoded" \
          --arg token "$encoded" \
          --argjson timestamp "$timestamp" \
          '{ text: $text, token: $token, timestamp: $timestamp, favorite: true }'
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
      timestamp="$(awk -F '\t' -v id="$1" '$1 == id { print $2; exit }' "$METADATA_FILE")"
      timestamp="''${timestamp:-0}"
      content_hash="$(awk -F '\t' -v id="$1" '$1 == id { print $3; exit }' "$METADATA_FILE")"
      content_hash="''${content_hash:-$(printf '%s\t' "$1" | cliphist decode | sha256sum | cut -d ' ' -f 1)}"

      exec 9>>"$FAVORITES_FILE"
      flock 9
      awk -F '\t' -v token="$encoded" '
        { value = NF >= 3 ? $NF : $1 }
        value == token { found = 1 }
        END { exit !found }
      ' "$FAVORITES_FILE" || printf '%s\t%s\t%s\t%s\n' \
        "$timestamp" "$1" "$content_hash" "$encoded" >&9
    }

    remove_history() {
      raw="$(printf '%s' "$1" | base64 --decode)"
      id="''${raw%%$'\t'*}"
      printf '%s' "$raw" | cliphist delete

      temporary_file="$(mktemp "''${METADATA_FILE}.XXXXXX")"
      awk -F '\t' -v id="$id" '$1 != id' "$METADATA_FILE" >"$temporary_file"
      mv "$temporary_file" "$METADATA_FILE"
    }

    remove_favorite() {
      ensure_favorites_file

      temporary_file="$(mktemp "''${FAVORITES_FILE}.XXXXXX")"
      trap 'rm -f "$temporary_file"' EXIT
      awk -F '\t' -v token="$1" '{ value = NF >= 3 ? $NF : $1 } value != token' \
        "$FAVORITES_FILE" >"$temporary_file"
      mv "$temporary_file" "$FAVORITES_FILE"
      trap - EXIT
    }

    clear_favorites() {
      ensure_favorites_file
      : >"$FAVORITES_FILE"
    }

    clear_history() {
      cliphist wipe
      : >"$METADATA_FILE"
    }

    case "''${1-}" in
      --history)          list_history ;;
      --favorites)        list_favorites ;;
      --copy-history)     copy_history "''${2:?Missing cliphist id}" ;;
      --copy-favorite)    copy_favorite "''${2:?Missing favorite token}" ;;
      --add-favorite)     add_favorite "''${2:?Missing cliphist id}" ;;
      --remove-history)   remove_history "''${2:?Missing history token}" ;;
      --remove-favorite)  remove_favorite "''${2:?Missing favorite token}" ;;
      --clear-history)    clear_history ;;
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
