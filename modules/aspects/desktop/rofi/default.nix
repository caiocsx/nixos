{ den, ... }:
{
  den.aspects.rofi = {
    includes = [
      den.aspects.power-menu
      den.aspects.launcher
      den.aspects.character-picker
      den.aspects.calculator
      den.aspects.network-manager
      den.aspects.wallpaper-picker
    ];

    homeManager =
      { pkgs, ... }:
      {
        imports = [ ./config/_desktop-entries.nix ];

        programs.rofi = {
          enable = true;
        };
      };
  };
}
