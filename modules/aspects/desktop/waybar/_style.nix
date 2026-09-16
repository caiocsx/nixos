{ ui }:

let
  cssVars = import ../theme/_css-theme.nix { inherit ui; };
in
''
  ${cssVars}

  @keyframes battery-blink {
    from {
      opacity: 1;
    }
    to {
      opacity: 0.3;
    }
  }

  * {
    all: unset;
    box-shadow: none;
    border: none;
    min-height: 25px;
    font-family: '${ui.font.propo}';
    font-size: 15px;
  }

  window#waybar {
    background-color: transparent;
  }

  tooltip {
    border: 2px solid @surface;
    background: @bg;
    border-radius: ${toString ui.border.radius}px;
  }

  tooltip label {
    font-size: 14px;
    color: @fg;
  }

  #custom-notification,
  #clock,
  #privacy,
  #tray,
  #group-tools,
  #pulseaudio.microphone,
  #pulseaudio,
  #backlight,
  #group-system {
    min-width: 25px;
    padding: 0 10px;
    margin: 0 4px;
    color: @fg;
    background-color: @bg;
    border-radius: ${toString ui.border.radius}px;
  }

  #custom-notification:hover,
  #clock:hover,
  #privacy:hover,
  #custom-cliphist:hover,
  #custom-bluefilter:hover,
  #custom-tools:hover,
  #custom-arrow-left:hover,
  #pulseaudio.microphone:hover,
  #pulseaudio:hover,
  #backlight:hover,
  #bluetooth:hover,
  #network:hover,
  #battery:hover,
  #custom-power:hover {
    transition: all 0.3s ease;
    color: @blue;
  }

  /* Modules Left */
  #clock {
    padding: 0 15px;
    font-size: 14px;
  }

  #tray window decoration {
    padding: 6px 12px;
    background-color: alpha(@bg, 0.9);
    border-radius: ${toString ui.border.radius}px;
  }

  /* Modules Center */
  #workspaces {
    padding: 0px 10px;
    background-color: @bg;
    border-radius: ${toString ui.border.radius}px;
  }

  #workspaces button {
    padding: 0 5px;
    color: alpha(@muted, 0.4);
    transition: all 0.2s ease;
  }

  #workspaces button:hover {
    color: rgba(0, 0, 0, 0);
    text-shadow: 0px 0px 1.5px rgba(0, 0, 0, 0.5);
    transition: all 0.5s ease;
  }

  #workspaces button.active {
    color: @muted;
    text-shadow: 0px 0px 2px rgba(0, 0, 0, 0.5);
  }

  #workspaces button.empty {
    color: rgba(0, 0, 0, 0);
    text-shadow: 0px 0px 1.5px rgba(0, 0, 0, 0.2);
  }

  #workspaces button.empty:hover {
    color: rgba(0, 0, 0, 0);
    text-shadow: 0px 0px 1.5px rgba(0, 0, 0, 0.5);
    transition: all 0.5s ease;
  }

  #workspaces button.empty.active {
    color: @muted;
    text-shadow: 0px 0px 2px rgba(0, 0, 0, 0.5);
  }

  /* Modules Right */
  #custom-cliphist,
  #custom-colorpicker,
  #custom-bluefilter,
  #custom-tools,
  #bluetooth,
  #network,
  #battery,
  #custom-power {
    padding: 0 8px;
  }

  #pulseaudio-slider,
  #backlight-slider {
    padding: 0 10px;
    background-color: @bg;
    border-radius: ${toString ui.border.radius}px;
  }

  #pulseaudio-slider slider,
  #backlight-slider slider {
    min-height: 0px;
    min-width: 0px;
  }

  #pulseaudio-slider trough,
  #backlight-slider trough {
    min-height: 8px;
    min-width: 100px;
    background-color: @surface;
    border-radius: ${toString ui.border.radius}px;
  }

  #pulseaudio-slider highlight,
  #backlight-slider highlight {
    min-width: 8px;
    min-height: 8px;
    background-color: @fg;
    border-radius: ${toString ui.border.radius}px;
  }

  #battery.charging.warning,
  #battery.charging.critical {
    color: @green;
    animation: battery-blink 2s ease-in-out infinite alternate;
  }

  #battery.charging.warning:hover,
  #battery.charging.critical:hover {
    color: @green;
  }

  #battery.warning {
    color: @yellow;
    animation: battery-blink 2s ease-in-out infinite alternate;
  }

  #battery.warning:hover {
    color: @yellow;
  }

  #battery.critical {
    color: @red;
    animation: battery-blink 0.8s linear infinite alternate;
  }

  #battery.critical:hover {
    color: @red;
  }
''
