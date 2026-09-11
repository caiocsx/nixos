{ den, lib, ... }:
{
  den.default.nixos.system.stateVersion = "25.11";
  den.default.homeManager.home.stateVersion = "25.11";
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.default.includes = [
    den.batteries.hostname

    den.aspects.boot
    den.aspects.nix
    den.aspects.nixpkgs
    den.aspects.audio
    den.aspects.security
    den.aspects.locale
    den.aspects.time
    den.aspects.system-defaults
    den.aspects.networking
    den.aspects.bluetooth
    den.aspects.core-packages
  ];
}
