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
          pkgs.pavucontrol
          pkgs.playerctl
        ];
      };
  };
}
