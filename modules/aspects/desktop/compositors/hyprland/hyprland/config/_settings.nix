{ ui }:
{
  config = {
    general = {
      border_size = ui.border.width;
      gaps_in = ui.spacing.gapsIn;
      gaps_out = ui.spacing.gapsOut;
      layout = "dwindle";
      "col.active_border" = ui.colors.accent;
      "col.inactive_border" = ui.colors.surface;
    };

    dwindle = {
      preserve_split = true;
      force_split = 2;
    };

    decoration = {
      rounding = ui.border.radius;
      active_opacity = ui.opacity.windowActive;
      inactive_opacity = ui.opacity.windowInactive;
      blur = {
        enabled = true;
        size = ui.blur.size;
        passes = ui.blur.passes;
        popups = true;
        input_methods = true;
      };
    };

    cursor = {
      hide_on_key_press = true;
      inactive_timeout = 10;
      no_warps = true;
      enable_hyprcursor = true;
      no_hardware_cursors = true;
    };

    input = {
      follow_mouse = 2;
      sensitivity = 0;
      force_no_accel = true;
    };

    ecosystem = {
      no_donation_nag = true;
      no_update_news = true;
    };

    xwayland = {
      force_zero_scaling = true;
    };

    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      font_family = ui.font.propo;
      focus_on_activate = true;
      close_special_on_empty = true;
      mouse_move_enables_dpms = true;
      key_press_enables_dpms = true;
    };

    render = {
      direct_scanout = false;
    };
  };
}
