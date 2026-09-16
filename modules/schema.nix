{ lib, ... }:
{
  den.schema.host.imports = [
    (_: {
      options = {
        compositor = lib.mkOption {
          type = lib.types.str;
          default = "hyprland";
          description = "Primary Wayland compositor/session for this host.";
        };

        defaultSession = lib.mkOption {
          type = lib.types.str;
          default = "hyprland-uwsm";
          description = "Session ID passed to displayManager.defaultSession (matches the .desktop session entry).";
        };
      };
    })
  ];
}
