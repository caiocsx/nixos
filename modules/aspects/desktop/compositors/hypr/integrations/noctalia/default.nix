{ den, ... }:
{
  den.aspects.hyprland-noctalia-integration.homeManager =
    { lib, ... }:
    let
      binds = import ./_binds.nix { inherit lib; };
    in
    {
      wayland.windowManager.hyprland.settings.bind = lib.mkAfter binds;
    };
}
