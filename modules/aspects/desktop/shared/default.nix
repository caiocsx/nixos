{ den, ... }:
{
  den.aspects.desktop-shared = {
    includes = [
      den.aspects.theme
      den.aspects.xdg
      den.aspects.wallpapers
    ];
  };
}
