{ den, ... }:
{
  den.aspects.hyprland-suite = {
    includes = [
      den.aspects.hyprland
      den.aspects.hypridle
      den.aspects.hyprlock
      den.aspects.hyprsunset
    ];

    homeManager =
      { pkgs, ... }:
      {
        imports = [ ./_session.nix ];

        home.packages = [
          pkgs.hyprpicker
          pkgs.hyprshutdown
        ];

        services.polkit-gnome.enable = true;
      };
  };
}
