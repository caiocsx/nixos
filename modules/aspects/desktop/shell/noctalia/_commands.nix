{
  config,
  lib,
  pkgs,
  ...
}:
let
  noctalia = lib.getExe config.programs.noctalia.package;
  wrap =
    name: command:
    pkgs.writeShellApplication {
      inherit name;
      text = "exec ${noctalia} msg ${command}";
    };
in
{
  home.packages = [
    (wrap "window-switcher" "window-switcher")
    (wrap "shell-settings" "settings-toggle")
  ];
}
