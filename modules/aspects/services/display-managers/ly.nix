{ ... }:
{
  den.aspects.ly.nixos =
    {
      config,
      host,
      lib,
      ...
    }:
    let
      cfg = config.services.displayManager.ly;
    in
    {
      options.services.displayManager.ly.animation = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "none"
            "colormix"
            "doom"
            "gameoflife"
            "matrix"
          ]
        );
        default = "matrix";
        description = "Background animation for the Ly display manager.";
      };

      config = {
        services.displayManager = {
          defaultSession = host.defaultSession;
          ly = {
            enable = true;
            x11Support = false;
            settings = {
              animation = cfg.animation;
              clock = "%H:%M";
              hide_borders = true;
              hide_key_hints = false;
              save = true;
              load = true;
              bigclock = true;
              default_input = "password";
              clear_password = true;
            };
          };
        };
      };
    };
}
