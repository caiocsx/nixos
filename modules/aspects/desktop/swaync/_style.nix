{ ui }:

let
  cssVars = import ../theme/_css-theme.nix { inherit ui; };
in
''
  ${cssVars}

  * {
    outline: none;
    box-shadow: none;
    color: @fg;
    font-size: 1rem;
    font-family: '${ui.font.propo}';
  }

  .control-center {
    background-color: @bg;
    border-radius: ${toString ui.border.radius}px;
  }

  .control-center-list {
    background-color: transparent;
  }

  .control-center .notification-background .close-button,
  .notification-group-close-button {
    opacity: 0;
  }

  .notification-group {
    background-color: transparent;
  }

  .notification {
    padding: 6px;
    background-color: @bg;
    border-radius: ${toString ui.border.radius}px;
  }

  .notification * {
    background-color: transparent;
  }

  .right * {
    opacity: 0;
  }

  .notification-content {
    margin-top: 4px;
    padding: 4px;
  }

  .summary {
    padding-top: 2px;
    font-weight: bold;
  }

  .time {
    padding-top: 2px;
    color: @muted;
  }

  .body {
    padding-top: 4px;
    font-size: 0.9rem;
  }

  .notification image {
    margin-right: 12px;
    border-radius: 0;
  }

  .widget-mpris-title {
    font-size: 1.1rem;
    font-weight: 700;
  }

  .widget-title > button {
    padding: 2px 16px;
    border-radius: 12px;
    background-color: alpha(@red, 0.5);
    transition: all 0.4s ease-in-out;
  }

  .widget-title > button:hover {
    background-color: @red;
    box-shadow: 0px 0px 5px red;
  }

  .widget-title > * ,
  .widget-title > button > * {
    font-size: 1.2rem;
  }

  .widget-dnd > * {
    font-size: 1.2rem;
  }

  .widget-dnd > switch {
    border-radius: 12px;
    background-color: alpha(@muted, 0.5);
  }

  .widget-dnd > switch:checked {
    background-color: @fg;
  }

  .widget-dnd > switch slider {
    background-color: @bg;
    border-radius: 10px;
  }

  .widget-dnd > switch:checked slider {
    background-color: @surface;
    border-radius: 10px;
  }

  .widget-buttons-grid {
    margin: 10px;
    background-color: transparent;
  }

  .widget-buttons-grid > flowbox > flowboxchild > button {
    padding: 10px 8px;
    background-color: transparent;
    border-radius: ${toString ui.border.radius}px;
    box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.2), 0 0 8px rgba(0, 0, 0, 0.3);
  }

  .widget-buttons-grid > flowbox > flowboxchild > button:hover {
    background-color: @blue;
    box-shadow: 0px 0px 2px rgba(0, 0, 0, 0.2);
    transition: all 0.5s ease;
  }

  .widget-buttons-grid > flowbox > flowboxchild > button label {
    font-size: 1.2rem;
    transition: all 0.7s ease;
  }

  .widget-buttons-grid > flowbox > flowboxchild > button:hover label {
    color: @bg;
    transition: all 0.7s ease;
  }

  .widget-buttons-grid > flowbox > flowboxchild > button.toggle:checked {
    background-color: @blue;
  }

  .widget-buttons-grid > flowbox > flowboxchild > button.toggle:checked label {
    color: @bg;
  }
''
