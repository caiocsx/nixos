{
  config,
  pkgs,
}:
pkgs.writeShellApplication {
  name = "cliphist-store";
  runtimeInputs = [
    pkgs.cliphist
    pkgs.coreutils
    pkgs.gawk
    pkgs.util-linux
  ];
  text = ''
    readonly METADATA_FILE="${config.xdg.cacheHome}/clipboard/history_metadata"

    input_file="$(mktemp)"
    ids_file="$(mktemp)"
    metadata_file="$(mktemp)"
    trap 'rm -f "$input_file" "$ids_file" "$metadata_file"' EXIT
    cat >"$input_file"

    mkdir -p "$(dirname "$METADATA_FILE")"
    touch "$METADATA_FILE"

    previous_id="$(cliphist list 2>/dev/null | head -n 1 | cut -f 1 || true)"
    cliphist -max-items ${toString config.clipboard.maxItems} store <"$input_file"
    current_id="$(cliphist list 2>/dev/null | head -n 1 | cut -f 1 || true)"

    exec 9>>"$METADATA_FILE"
    flock 9

    cliphist list 2>/dev/null | cut -f 1 >"$ids_file" || true
    awk -F '\t' 'NR == FNR { ids[$1] = 1; next } $1 in ids' \
      "$ids_file" "$METADATA_FILE" >"$metadata_file"

    if [[ "''${CLIPBOARD_STATE-}" != "clear" && -n "$current_id" && "$current_id" != "$previous_id" ]]; then
      content_hash="$(sha256sum "$input_file" | cut -d ' ' -f 1)"
      printf '%s\t%s\t%s\n' "$current_id" "$(date +%s)" "$content_hash" >>"$metadata_file"
    fi

    mv "$metadata_file" "$METADATA_FILE"
  '';
}
