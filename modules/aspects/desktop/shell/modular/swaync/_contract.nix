{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "control-center-toggle";
      runtimeInputs = [ pkgs.swaynotificationcenter ];
      text = "exec swaync-client -t -sw";
    })
  ];
}
