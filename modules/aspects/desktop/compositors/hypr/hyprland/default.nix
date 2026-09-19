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
        withUWSM = true;
        xwayland.enable = true;
      };
    };

    homeManager =
      {
        config,
        lib,
        ui,
        ...
      }:
      let
        rules = import ./config/_rules.nix { };
        settings = import ./config/_settings.nix { inherit ui; };
        animations = import ./config/_animations.nix { inherit lib; };
        binds = import ./config/_binds.nix { inherit lib; };
      in
      {
        home.sessionVariables = {
          CLUTTER_BACKEND = "wayland";
          ELECTRON_OZONE_PLATFORM_HINT = "wayland";
          GDK_BACKEND = "wayland,x11,*";
          MOZ_ENABLE_WAYLAND = "1";
          NIXOS_OZONE_WL = "1";
          OZONE_PLATFORM = "wayland";
          QT_AUTO_SCREEN_SCALE_FACTOR = "1";
          QT_QPA_PLATFORM = "wayland;xcb";
          QT_QPA_PLATFORMTHEME = "qt5ct";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          SDL_VIDEODRIVER = "wayland,x11";
        };

        xdg.configFile."uwsm/env".source =
          "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = false;
          configType = "lua";
          settings = settings // rules // animations // { bind = binds; };
        };
      };
  };
}
