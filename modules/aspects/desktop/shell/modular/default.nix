{ den, ... }:
{
  den.aspects.modular-shell = {
    includes = [
      den.aspects.rofi
      den.aspects.swaync
      den.aspects.waybar
      den.aspects.clipboard-history
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.bluetui
          pkgs.pavucontrol
        ];
      };
  };
}
