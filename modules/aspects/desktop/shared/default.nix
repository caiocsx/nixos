{ den, ... }:
{
  den.aspects.desktop-shared = {
    includes = [
      den.aspects.theme
      den.aspects.xdg
      den.aspects.wallpapers
      den.aspects.power-profiles
      den.aspects.flatpak
    ];

    homeManager =
      { pkgs, ... }:
      {
        services.polkit-gnome.enable = true;

        home.packages = [
          pkgs.playerctl
        ];
      };
  };
}
