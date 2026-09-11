{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "hyprsunset-toggle";
  runtimeInputs = [ pkgs.coreutils ];
  text = ''
    STATE_DIR="$HOME/.local/state"
    STATE_FILE="$STATE_DIR/hyprsunset-enabled"

    mkdir -p "$STATE_DIR"

    if systemctl --user is-active --quiet hyprsunset.service; then
      systemctl --user stop hyprsunset.service
      echo 0 > "$STATE_FILE"
    else
      systemctl --user start hyprsunset.service
      echo 1 > "$STATE_FILE"
    fi
  '';
}
