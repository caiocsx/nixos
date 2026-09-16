{ den, ... }:
{
  den.aspects.desktop-shared = {
    includes = [
      den.aspects.theme
      den.aspects.xdg
      den.aspects.wallpapers
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.networkmanagerapplet
          pkgs.pavucontrol
          pkgs.playerctl
        ];
      };
  };
}
