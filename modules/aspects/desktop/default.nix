{ den, ... }:
{
  den.aspects.desktop = {
    includes = [
      den.aspects.hyprland-suite
      den.aspects.desktop-shell
      den.aspects.desktop-shared
    ];
  };
}
