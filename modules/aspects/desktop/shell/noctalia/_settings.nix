{ config, nixLogo, ... }:
{
  shell = {
    screenshot = {
      annotate = true;
      confirm_region = true;
      directory = "${config.home.homeDirectory}/Pictures/Screenshots";
      filename_pattern = "%Y-%m-%d_%H-%M-%S";
      skip_annotate_on_copy_save = true;
    };

    greeter_sync = {
      auto_sync = true;
    };

    session.show_shortcuts = false;
  };

  idle = {
    behavior_order = [
      "lock"
      "screen-off"
      "suspend"
    ];
    pre_action_fade_seconds = 2.0;

    behavior = {
      lock = {
        timeout = 600;
        action = "lock";
        enabled = true;
      };
      screen-off = {
        timeout = 1200;
        action = "screen_off";
        enabled = true;
      };
      suspend = {
        timeout = 2400;
        action = "lock_and_suspend";
        enabled = true;
      };
    };
  };

  theme = {
    builtin = "Nord";
    custom_palette = "stylix";
    mode = "dark";
    shell_mode = "dark";
    source = "custom";
  };

  plugins.enabled = [
    "dotnetrob/cat"
    "kenn/keybind-cheatsheet"
  ];

  bar.default = {
    capsule = true;
    start = [
      "launcher"
      "workspaces"
      "audio_visualizer"
    ];
    center = [
      "cat"
      "clock"
      "wallpaper"
    ];
    end = [
      "tray"
      "group:g3"
      "group:g2"
      "group:g1"
    ];
    margin_ends = 0;
    radius = 0;
    thickness = 35;

    capsule_group = [
      {
        accordion = false;
        accordion_direction = "end";
        enabled = true;
        fill = "surface_variant";
        id = "g1";
        members = [
          "bluetooth"
          "network"
          "battery"
          "session"
        ];
        opacity = 1.0;
        padding = 6.0;
      }
      {
        accordion = false;
        accordion_direction = "end";
        enabled = true;
        fill = "surface_variant";
        id = "g2";
        members = [
          "input_volume"
          "volume"
          "brightness"
        ];
        opacity = 1.0;
        padding = 6.0;
      }
      {
        accordion = false;
        accordion_direction = "start";
        enabled = true;
        fill = "surface_variant";
        id = "g3";
        members = [ "keybinds_2" ];
        opacity = 1.0;
        padding = 6.0;
      }
    ];
  };

  widget = {
    cat.type = "dotnetrob/cat:cat";
    clock.format = "{:%H:%M · %a, %d %b}";
    input_volume.show_label = false;
    keybinds_2.type = "kenn/keybind-cheatsheet:keybinds";
    launcher.custom_image = toString nixLogo;
    media = {
      hide_when_no_media = true;
      max_length = 200;
    };
    network = {
      scale = 0.95;
      show_label = false;
    };
    tray = {
      drawer = true;
    };
  };

  nightlight = {
    enabled = true;
    temperature_night = 4400;
  };
}
