{ den, ... }:
{
  den.aspects.rofi = {
    includes = [
      den.aspects.power-menu
      den.aspects.clipboard
      den.aspects.launcher
      den.aspects.character-picker
      den.aspects.wallpaper-picker
    ];

    homeManager =
      { pkgs, ... }:
      {
        programs.rofi = {
          enable = true;
        };

        xdg.dataFile = {
          "applications/rofi.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Name=Rofi
            Exec=true
            NoDisplay=true
          '';

          "applications/rofi-theme-selector.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Name=Rofi Theme Selector
            Exec=true
            NoDisplay=true
          '';
        };
      };
  };
}
