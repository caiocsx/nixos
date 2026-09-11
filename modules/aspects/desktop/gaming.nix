{ ... }:
{
  den.aspects.gaming = {
    nixos =
      { pkgs, ... }:
      {
        programs = {
          steam = {
            enable = true;
            extraCompatPackages = [ pkgs.proton-ge-bin ];
            protontricks.enable = true;
            remotePlay.openFirewall = true;
            localNetworkGameTransfers.openFirewall = true;
          };
          gamemode.enable = true;
        };
      };

    provides.to-users.homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.heroic
        pkgs.mangohud
      ];
    };
  };
}
