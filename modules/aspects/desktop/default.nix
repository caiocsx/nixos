{ den, ... }:
{
  den.aspects.desktop =
    { host, user, ... }:
    let
      compositors.hyprland = den.aspects.hyprland-compositor;
      shells = {
        modular = den.aspects.modular-shell;
        noctalia = den.aspects.noctalia;
      };
      integrations.hyprland = {
        modular = den.aspects.hyprland-modular-integration;
        noctalia = den.aspects.hyprland-noctalia-integration;
      };
    in
    {
      includes = [
        compositors.${host.compositor}
        shells.${user.desktopShell}
        integrations.${host.compositor}.${user.desktopShell}
        den.aspects.desktop-shared
      ];
    };
}
