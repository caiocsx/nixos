{ ... }:
{
  positionX = "left";
  positionY = "top";
  layer = "overlay";
  cssPriority = "user";
  control-center-layer = "top";
  layer-shell = true;
  fit-to-screen = true;
  control-center-width = 450;
  control-center-margin-top = 8;
  control-center-margin-bottom = 8;
  control-center-margin-right = 0;
  control-center-margin-left = 8;
  notification-window-width = 350;
  notification-icon-size = 96;
  notification-body-image-width = 200;
  notification-body-image-height = 200;
  notification-2fa-action = true;
  notification-inline-replies = true;
  timeout-low = 3;
  timeout = 4;
  timeout-critical = 5;
  keyboard-shortcuts = true;
  image-visibility = "when-available";
  transition-time = 200;
  hide-on-clear = true;
  hide-on-action = true;
  script-fail-notify = true;
  widgets = [
    "mpris"
    "title"
    "dnd"
    "notifications"
    "buttons-grid"
  ];
  widget-config = {
    mpris = {
      show-album-art = "when-available";
      autohide = true;
    };
    title = {
      text = "Notifications";
      clear-all-button = true;
      button-text = "󰆴";
    };
    dnd = {
      text = "Do Not Disturb";
    };
    buttons-grid = {
      buttons-per-row = 4;
      actions = [
        {
          label = "";
          command = "swaync-client -cp && sleep 0.6 && hyprpicker -a -f hex -n";
        }
        {
          label = "󰃟";
          type = "toggle";
          command = "hyprsunset-toggle";
          update-command = ''
            sh -c 'systemctl --user is-active --quiet hyprsunset.service && echo true || echo false'
          '';
        }
        {
          label = "";
          command = "swaync-client -cp && screenshot --region";
        }
        {
          label = "";
          command = "kitty btop";
        }
      ];
    };
  };
}
