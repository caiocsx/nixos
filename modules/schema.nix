{ lib, ... }:
let
  defaultSessions.hyprland = "hyprland-uwsm";
in
{
  den.schema.host.imports = [
    ({ config, ... }: {
      options = {
        compositor = lib.mkOption {
          type = lib.types.enum [ "hyprland" ];
          default = "hyprland";
          description = "Primary Wayland compositor/session for this host.";
        };

        displayManager = lib.mkOption {
          type = lib.types.enum [
            "ly"
            "noctalia-greeter"
            "sddm"
          ];
          default = "ly";
          description = "Display manager used to start graphical sessions on this host.";
        };

        defaultSession = lib.mkOption {
          type = lib.types.str;
          default = defaultSessions.${config.compositor};
          description = "Session ID passed to displayManager.defaultSession (matches the .desktop session entry).";
        };
      };
    })
  ];

  den.schema.user.imports = [
    (_: {
      options.desktopShell = lib.mkOption {
        type = lib.types.enum [
          "modular"
          "noctalia"
        ];
        default = "modular";
        description = "Desktop shell implementation used for this host-user relationship.";
      };
    })
  ];
}
