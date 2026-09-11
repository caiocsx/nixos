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

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          pavucontrol
          playerctl
          networkmanagerapplet
          imagemagick
          ffmpeg
          jq
          tree
          nixfmt
          nh
          p7zip
          unzip
          zip
          gnutar
        ];
      };
  };
}
