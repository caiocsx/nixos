{ den, ... }:
{
  den.aspects.desktop = {
    includes = [
      den.aspects.hyprland-suite
      den.aspects.modular-shell
      den.aspects.desktop-shared
    ];
  };
}
