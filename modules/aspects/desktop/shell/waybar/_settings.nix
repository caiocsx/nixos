{ ui, ... }:
{
  # --- GENERAL SETTINGS ---
  layer = "top";
  position = "top";
  margin = "8px 8px 0 8px";

  # --- MODULES DEFINITION ---
  modules-left = [ "group/group-left" ];
  modules-center = [ "group/group-center" ];
  modules-right = [ "group/group-right" ];

  # --- MODULE LEFT SETTINGS ---
  "group/group-left" = {
    orientation = "inherit";
    modules = [
      "custom/notification"
      "clock"
      "privacy"
      "tray"
    ];
  };
  "custom/notification" = {
    format = "{icon}";
    format-icons = {
      notification = "󱅫";
      none = "󰂜";
      dnd-notification = "󰂠";
      dnd-none = "󰪓";
      inhibited-notification = "󰂛";
      inhibited-none = "󰪑";
      dnd-inhibited-notification = "󰂛";
      dnd-inhibited-none = "󰪑";
    };
    exec-if = "which swaync-client";
    exec = "swaync-client -swb";
    on-click = "swaync-client -t -sw";
    on-click-right = "swaync-client -d -sw";
    return-type = "json";
    tooltip = true;
    escape = true;
  };
  clock = {
    format = "{:%H:%M:%S}";
    format-alt = "{:%H:%M - %B %d, %Y}";
    tooltip-format = "<tt><small>{calendar}</small></tt>";
    calendar = {
      mode = "year";
      mode-mon-col = 3;
      weeks-pos = "right";
      on-scroll = 1;
      format = {
        months = "<span color='${ui.colors.blue}'><b>{}</b></span>";
        days = "<span color='${ui.colors.fg}'><b>{}</b></span>";
        weeks = "<span color='${ui.colors.cyan}'><b>W{}</b></span>";
        weekdays = "<span color='${ui.colors.muted}'><b>{}</b></span>";
        today = "<span color='${ui.colors.red}'><b><u>{}</u></b></span>";
      };
    };
    actions = {
      on-click-right = "mode";
      on-scroll-up = "shift_up";
      on-scroll-down = "shift_down";
    };
    interval = 1;
  };
  privacy = {
    modules = [
      {
        type = "screenshare";
        tooltip = false;
      }
      {
        type = "audio-in";
        tooltip = false;
      }
      {
        type = "location";
        icon-name = "location-services-active-symbolic";
      }
    ];
    icon-size = 14;
    icon-spacing = 10;
    transition-duration = 250;
  };
  tray = {
    icon-size = 14;
    spacing = 10;
  };

  # --- MODULE CENTER SETTINGS ---
  "group/group-center" = {
    orientation = "inherit";
    modules = [ "hyprland/workspaces" ];
  };
  "hyprland/workspaces" = {
    format = "{icon}";
    format-icons = {
      active = "󰝥";
      default = "󰝥";
      empty = "󰝥";
    };
    persistent-workspaces = {
      "*" = [
        1
        2
        3
        4
        5
      ];
    };
  };

  # --- MODULE RIGHT SETTINGS ---
  "group/group-right" = {
    orientation = "inherit";
    modules = [
      "group/group-tools"
      "pulseaudio#microphone"
      "group/audio"
      "group/brightness"
      "group/group-system"
    ];
  };
  "group/group-tools" = {
    orientation = "inherit";
    modules = [
      "group/tools-drawer"
      "custom/tools"
    ];
  };
  "custom/tools" = {
    format = "󱌣";
    tooltip = false;
  };
  "group/tools-drawer" = {
    orientation = "inherit";
    drawer = {
      children-class = "tools";
      transition-left-to-right = true;
      click-to-reveal = true;
      transition-duration = 400;
    };
    modules = [
      "custom/arrow-left"
      "custom/cliphist"
      "custom/colorpicker"
      "custom/bluefilter"
    ];
  };
  "custom/arrow-left" = {
    format = "󰅁";
    tooltip = false;
    cursor = true;
  };
  "custom/cliphist" = {
    format = "󱉨";
    on-click = "clipboard";
    on-click-right = "clipboard --wipe";
    tooltip = false;
  };
  "custom/colorpicker" = {
    format = "{}";
    on-click = "colorpicker";
    exec = "colorpicker --json";
    return-type = "json";
    interval = "once";
    tooltip = true;
    signal = 1;
  };
  "custom/bluefilter" = {
    format = "{}";
    on-click = "bluefilter --toggle";
    exec = "bluefilter";
    tooltip = false;
    interval = "once";
    signal = 1;
  };
  "pulseaudio#microphone" = {
    format = "{format_source}";
    format-source = "󰍬";
    format-source-muted = "󰍭";
    on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    on-scroll-up = "";
    on-scroll-down = "";
    tooltip = false;
  };

  "group/audio" = {
    orientation = "inherit";
    drawer = {
      children-class = "audio";
      transition-left-to-right = false;
      transition-duration = 400;
    };
    modules = [
      "pulseaudio"
      "pulseaudio/slider"
    ];
  };
  "pulseaudio/slider" = {
    orientation = "horizontal";
    min = 0;
    max = 100;
  };
  pulseaudio = {
    format = "{icon}";
    format-muted = "󰝟";
    format-icons = {
      headphone = "󰋋";
      headset = "󰋎";
      headset-muted = "󰋐";
      default = [
        "󰕿"
        "󰖀"
        "󰕾"
      ];
    };
    on-click = "pavucontrol";
    on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    tooltip-format = "Volume: {volume}%";
    ignored-sinks = [ "Easy Effects Sink" ];
    tooltip = true;
  };

  "group/brightness" = {
    orientation = "inherit";
    drawer = {
      children-class = "brightness";
      transition-left-to-right = false;
      transition-duration = 400;
    };
    modules = [
      "backlight"
      "backlight/slider"
    ];
  };
  "backlight/slider" = {
    orientation = "horizontal";
    min = 5;
    max = 100;
  };
  backlight = {
    format = "{}";
    format-icons = [
      "󰃞"
      "󰃝"
      "󰃟"
      "󰃠"
    ];
    tooltip-format = "Brightness: {percent}%";
    tooltip = true;
  };

  "group/group-system" = {
    orientation = "inherit";
    modules = [
      "bluetooth"
      "network"
      "battery"
      "custom/power"
    ];
  };
  bluetooth = {
    format-on = "󰂯";
    format-off = "󰂲";
    format-disabled = "󰂲";
    format-connected = "󰂱";
    format-no-controller = "󰂳";
    tooltip-format = "{device_enumerate}";
    tooltip-format-enumerate-connected = "{device_address}";
    tooltip-format-enumerate-connected-battery = "{device_alias} | Battery {device_battery_percentage}%";
    on-click = "blueman-manager";
    on-click-right = "rfkill toggle bluetooth";
    tooltip = true;
  };

  network = {
    format-icons = {
      wifi = "󰖩";
      ethernet = "󰈀";
      linked = "󰲝";
      disabled = "󰖪";
      disconnected = "󰀝";
    };
    format-wifi = "{icon}";
    format-ethernet = "{icon}";
    format-linked = "{icon}";
    format-disconnected = "{icon}";
    format-disabled = "{icon}";
    tooltip-format = "{ifname}";
    tooltip-format-wifi = "{essid}\nSignal: {signalStrength}%\nIP: {ipaddr}/{cidr}\n↓ {bandwidthDownBytes}  ↑ {bandwidthUpBytes}";
    tooltip-format-ethernet = "{ifname}\nIP: {ipaddr}/{cidr}\n↓ {bandwidthDownBytes}  ↑ {bandwidthUpBytes}";
    tooltip-format-linked = "{ifname}\nConnected, waiting for IP";
    tooltip-format-disconnected = "Disconnected";
    tooltip-format-disabled = "Disabled";
    on-click = " nm-connection-editor";
    on-click-right = "kitty -e nmtui";
    tooltip = true;
    max-length = 20;
    interval = 5;
  };
  battery = {
    states = {
      warning = 20;
      critical = 10;
    };
    events = {
      on-charging = "notify-send -u normal 'Power' 'Connected to AC power'";
      on-charging-100 = "notify-send -u normal 'Battery' 'Battery is fully charged'";
      on-discharging = "notify-send -u normal 'Power' 'Running on battery'";
      on-discharging-warning = "notify-send -u normal 'Battery Warning' 'Battery level is low'";
      on-discharging-critical = "notify-send -u critical 'Battery Critical' 'Battery level is critically low'";
    };
    format = "{icon}";
    format-icons = {
      default = [
        "󰂎"
        "󰁺"
        "󰁻"
        "󰁼"
        "󰁽"
        "󰁾"
        "󰁿"
        "󰂀"
        "󰂁"
        "󰂂"
        "󰁹"
      ];
      charging = [
        "󰢟"
        "󰢜"
        "󰂆"
        "󰂇"
        "󰂈"
        "󰢝"
        "󰂉"
        "󰢞"
        "󰂊"
        "󰂋"
        "󰂅"
      ];
    };
    format-critical = "󰂃";
    tooltip-format = "{capacity}% - {time} remaining";
    tooltip-format-charging = "Charging: {capacity}% - {time} until full";
    tooltip = true;
    interval = 10;
  };
  "custom/power" = {
    format = "󰤆";
    on-click = "power-menu";
    tooltip = false;
  };
}
