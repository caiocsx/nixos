{ den, ... }:
{
  den.aspects.desktop-shell.includes = [
    den.aspects.rofi
    den.aspects.swaync
    den.aspects.waybar
    den.aspects.awww
    den.aspects.clipboard
    den.aspects.screenshot
  ];
}
