{ ... }:
{
  den.aspects.core-packages.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.git
        pkgs.curl
        pkgs.wget
        pkgs.nano
        pkgs.psmisc
        pkgs.xdg-utils
        pkgs.util-linux
        pkgs.procps
        pkgs.pciutils
        pkgs.usbutils
        pkgs.hwinfo
        pkgs.lm_sensors
      ];
    };
}
