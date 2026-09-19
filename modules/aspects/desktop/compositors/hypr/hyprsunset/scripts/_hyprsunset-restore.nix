{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "hyprsunset-restore";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.systemd
  ];
  text = ''
    STATE_FILE="$HOME/.local/state/hyprsunset-enabled"

    if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
      systemctl --user start hyprsunset.service
    fi
  '';
}
