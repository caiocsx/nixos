{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "session-exit";
      runtimeInputs = [ pkgs.hyprshutdown ];
      text = "exec hyprshutdown";
    })
    (pkgs.writeShellApplication {
      name = "session-lock";
      runtimeInputs = [ pkgs.hyprlock ];
      text = "exec hyprlock";
    })
  ];
}
