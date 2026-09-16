{ ... }:
let
  mkEnv = key: val: ''hl.env("${key}", "${val}")'';
in
[
  # --- Wayland & Ozone ---
  (mkEnv "NIXOS_OZONE_WL" "1")
  (mkEnv "ELECTRON_OZONE_PLATFORM_HINT" "wayland")
  (mkEnv "OZONE_PLATFORM" "wayland")
  (mkEnv "MOZ_ENABLE_WAYLAND" "1")

  # --- Toolkits ---
  (mkEnv "SDL_VIDEODRIVER" "wayland,x11")
  (mkEnv "CLUTTER_BACKEND" "wayland")
  (mkEnv "GDK_BACKEND" "wayland,x11,*")

  # --- Qt ---
  (mkEnv "QT_QPA_PLATFORM" "wayland;xcb")
  (mkEnv "QT_QPA_PLATFORMTHEME" "qt5ct")
  (mkEnv "QT_AUTO_SCREEN_SCALE_FACTOR" "1")
  (mkEnv "QT_WAYLAND_DISABLE_WINDOWDECORATION" "1")

  # --- XDG ---
  (mkEnv "XDG_CURRENT_DESKTOP" "Hyprland")
  (mkEnv "XDG_SESSION_TYPE" "wayland")
  (mkEnv "XDG_SESSION_DESKTOP" "Hyprland")
]
