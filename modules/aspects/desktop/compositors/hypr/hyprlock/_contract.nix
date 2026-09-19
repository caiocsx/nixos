{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "session-lock";
      runtimeInputs = [
        pkgs.hyprlock
        pkgs.procps
      ];
      text = "pidof hyprlock || exec hyprlock";
    })
  ];
}
