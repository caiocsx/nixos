{ den, ... }:
{
  den.aspects.desktop = {
    includes = [
      den.aspects.hyprland-suite
      den.aspects.rofi
      den.aspects.waybar
      den.aspects.swaync
      den.aspects.clipboard
      den.aspects.theme
      den.aspects.xdg
      den.aspects.wallpapers
    ];
  };
}
