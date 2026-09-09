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
    format = "<span size='12pt'>{icon}</span>";
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
      active = "";
      default = "";
      empty = "";
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
      "pulseaudio#microphone"
      "group/audio"
      "group/brightness"
      "group/group-system"
    ];
  };
  "pulseaudio#microphone" = {
    format = "{format_source}";
    format-source = "<span size='13pt'>󰍬</span>";
    format-source-muted = "<span size='13pt'>󰍭</span>";
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
    format-muted = "<span size='11pt'></span>";
    format-icons = {
      headphone = "<span size='11pt'>󰋋</span>";
      headset = "<span size='11pt'>󰋎</span>";
      headset-muted = "<span size='11pt'>󰟎</span>";
      default = [
        "<span size='11pt'></span>"
        "<span size='11pt'></span>"
        "<span size='11pt'></span>"
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
    format = "<span size='11pt'>{icon}</span>";
    format-icons = [
      "<span size='11pt'>󰃞</span>"
      "<span size='11pt'>󰃝</span>"
      "<span size='11pt'>󰃟</span>"
      "<span size='11pt'>󰃠</span>"
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
    ];
  };
  bluetooth = {
    format-on = "<span size='13pt'>󰂯</span>";
    format-off = "<span size='13pt'>󰂲</span>";
    format-disabled = "<span size='13pt'>󰂲</span>";
    format-connected = "<span size='13pt'>󰂱</span>";
    format-no-controller = "<span size='13pt'>󰂯</span>";
    tooltip-format = "{device_enumerate}";
    tooltip-format-enumerate-connected = "{device_address}";
    tooltip-format-enumerate-connected-battery = "{device_alias} | Battery {device_battery_percentage}%";
    on-click = "blueman-manager";
    on-click-right = "rfkill toggle bluetooth";
    tooltip = true;
  };

  network = {
    format-icons = {
      wifi = [
        "<span size='12pt'>󰤯</span>"
        "<span size='12pt'>󰤟</span>"
        "<span size='12pt'>󰤢</span>"
        "<span size='12pt'>󰤥</span>"
        "<span size='12pt'>󰤨</span>"
      ];
      ethernet = "<span size='12pt'>󰈀</span>";
      linked = "<span size='12pt'>󰲝</span>";
      disabled = "<span size='12pt'>󰤭</span>";
      disconnected = "<span size='12pt'>󰲛</span>";
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
    on-click = "network-manager";
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
        "<span size='12pt'>󰂎</span>"
        "<span size='12pt'>󰁺</span>"
        "<span size='12pt'>󰁻</span>"
        "<span size='12pt'>󰁼</span>"
        "<span size='12pt'>󰁽</span>"
        "<span size='12pt'>󰁾</span>"
        "<span size='12pt'>󰁿</span>"
        "<span size='12pt'>󰂀</span>"
        "<span size='12pt'>󰂁</span>"
        "<span size='12pt'>󰂂</span>"
        "<span size='12pt'>󰁹</span>"
      ];
      charging = [
        "<span size='12pt'>󰢟</span>"
        "<span size='12pt'>󰢜</span>"
        "<span size='12pt'>󰂆</span>"
        "<span size='12pt'>󰂇</span>"
        "<span size='12pt'>󰂈</span>"
        "<span size='12pt'>󰢝</span>"
        "<span size='12pt'>󰂉</span>"
        "<span size='12pt'>󰢞</span>"
        "<span size='12pt'>󰂊</span>"
        "<span size='12pt'>󰂋</span>"
        "<span size='12pt'>󰂅</span>"
      ];
    };
    format-critical = "<span size='12pt'>󰂃</span>";
    tooltip-format = "{capacity}% - {time} remaining";
    tooltip-format-charging = "Charging: {capacity}% - {time} until full";
    tooltip = true;
    interval = 10;
  };
}
