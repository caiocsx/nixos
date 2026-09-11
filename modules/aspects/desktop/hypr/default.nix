{ den, ... }:
{
  den.aspects.hyprland-suite = {
    includes = [
      den.aspects.hyprland
      den.aspects.hypridle
      den.aspects.hyprlock
      den.aspects.hyprsunset
    ];

    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.hyprshot
        pkgs.hyprpicker
        pkgs.hyprshutdown
      ];

      services.polkit-gnome.enable = true;
    };
  };
}
