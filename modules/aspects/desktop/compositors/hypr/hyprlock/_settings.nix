{ config, ui, ... }:
let
  bg = ui.rgba ui.colors.bg ui.opacity.popups;
  fg = ui.rgb ui.colors.fg;
  muted = ui.rgb ui.colors.muted;
  accent = ui.rgb ui.colors.accent;

  red = ui.rgb ui.colors.red;
  orange = ui.rgb ui.colors.orange;
  yellow = ui.rgb ui.colors.yellow;
  purple = ui.rgb ui.colors.purple;
  magenta = ui.rgb ui.colors.magenta;

  font = ui.font.propo;
  fontBold = "${ui.font.mono} Bold";
in
{
  general = {
    hide_cursor = true;
    ignore_empty_input = true;
  };

  background = [
    {
      monitor = "";
      path = "${config.xdg.cacheHome}/wallpapers/lockscreen";
      color = bg;
      blur_size = ui.blur.size;
      blur_passes = ui.blur.passes;
      brightness = 0.6;
    }
  ];

  label = [
    {
      monitor = "";
      text = "cmd[update:1000] hyprlock-media";
      position = "10, 520";
      halign = "left";
      valign = "center";
      font_family = font;
      font_size = 11;
      color = fg;
    }
    {
      monitor = "";
      text = "cmd[update:1000] hyprlock-sys-status";
      position = "-15, 520";
      halign = "right";
      valign = "center";
      font_family = font;
      font_size = 11;
      color = fg;
    }
    {
      monitor = "";
      text = "cmd[update:1000] echo \"$(date +\"%A, %B %d\")\"";
      position = "0, 405";
      halign = "center";
      valign = "center";
      font_family = fontBold;
      font_size = 30;
      color = fg;
    }
    {
      monitor = "";
      text = "cmd[update:1000] echo \"$(date +\"%k:%M\")\"";
      position = "0, 310";
      halign = "center";
      valign = "center";
      font_family = fontBold;
      font_size = 100;
      color = fg;
    }
    {
      monitor = "";
      text = "cmd[update:100] hyprlock-lock-state";
      position = "0, -500";
      halign = "center";
      valign = "center";
      font_family = font;
      font_size = 10;
      color = fg;
    }
  ];
  input-field = [
    {
      monitor = "";
      size = "200, 30";
      position = "0, -468";
      halign = "center";
      valign = "center";
      fade_on_empty = true;
      font_family = font;
      font_color = fg;
      placeholder_text = " Enter Password";
      outline_thickness = 2;
      inner_color = "rgba(255, 255, 255, 0.1)";
      outer_color = "rgba(0, 0, 0, 0)";
      check_color = purple;
      capslock_color = orange;
      numlock_color = yellow;
      bothlock_color = magenta;
      fail_color = red;
      fail_text = "$FAIL <b>($ATTEMPTS)</b>";
      dots_size = 0.25;
      dots_spacing = 0.55;
      dots_center = true;
      dots_rounding = -1;
      hide_input = false;
    }
  ];
}
