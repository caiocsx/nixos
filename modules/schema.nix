{ lib, ... }:
{
  den.schema.host.imports = [
    (_: {
      options.compositor = lib.mkOption {
        type = lib.types.str;
        default = "hyprland";
        description = "Primary Wayland compositor/session for this host.";
      };
    })
  ];
}
