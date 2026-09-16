{ den, ... }:
{
  den.aspects.desktop-shell = {
    includes = [
      den.aspects.rofi
      den.aspects.swaync
      den.aspects.waybar
      den.aspects.awww
      den.aspects.clipboard
      den.aspects.screenshot
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.networkmanagerapplet
          pkgs.pavucontrol
          pkgs.playerctl
        ];

        xdg.configFile = {
          "autostart/blueman.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Hidden=true
          '';

          "autostart/nm-applet.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Hidden=true
          '';
        };
      };
  };
}
