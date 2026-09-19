{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "bar-toggle";
      runtimeInputs = [ pkgs.systemd ];
      text = ''
        if systemctl --user is-active --quiet waybar.service; then
          exec systemctl --user stop waybar.service
        else
          exec systemctl --user start waybar.service
        fi
      '';
    })
  ];
}
