{ ... }:
{
  den.aspects.networking = {
    nixos =
      { ... }:
      {
        networking = {
          networkmanager.enable = true;
          firewall.enable = true;
        };
      };

    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.networkmanagerapplet ];
    };
  };
}
