{ ... }:
let
  sessionNames.hyprland = "Hyprland (uwsm-managed)";
in
{
  den.aspects.noctalia-greeter.nixos =
    { host, pkgs, ... }:
    {
      services.displayManager.noctalia-greeter = {
        enable = true;

        cursorTheme = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
        };

        settings = {
          session.default = sessionNames.${host.compositor};
          cursor.size = 20;
          idle.timeout = 300;
          appearance = {
            scheme = "Synced";
            hide_logo = true;
          };
        };
      };
    };
}
