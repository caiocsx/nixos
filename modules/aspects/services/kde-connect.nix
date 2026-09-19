{ ... }:
{
  den.aspects.kde-connect = {
    nixos =
      { ... }:
      {
        programs.kdeconnect.enable = true;
      };
    homeManager =
      { ... }:
      {
        services.kdeconnect = {
          enable = true;
          indicator = true;
        };
      };
  };
}
