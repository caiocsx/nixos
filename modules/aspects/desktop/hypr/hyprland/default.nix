{ ... }:
{
  den.aspects.hyprland = {
    nixos = { pkgs, ... }: {
      xdg.portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-hyprland
        ];
      };
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };
    };

    homeManager =
      {
        lib,
        pkgs,
        ui,
        ...
      }:
      let
        env = import ./config/_env.nix { };
        autostart = import ./config/_autostart.nix { inherit lib; };
        rules = import ./config/_rules.nix { };
        settings = import ./config/_settings.nix { inherit ui; };
        animations = import ./config/_animations.nix { inherit lib; };
        binds = import ./config/_binds.nix { inherit lib; };
      in
      {
        wayland.windowManager.hyprland = {
          enable = true;
          systemd = {
            enable = true;
            variables = [ "--all" ];
          };
          configType = "lua";
          extraConfig = lib.concatStringsSep "\n" env;
          settings = settings // rules // animations // autostart // { bind = binds; };
        };
      };
  };
}
