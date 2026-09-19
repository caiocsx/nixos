{
  config,
  lib,
  pkgs,
  ...
}:
let
  noctalia = lib.getExe config.programs.noctalia.package;
  wrap =
    name: cmd:
    pkgs.writeShellApplication {
      inherit name;
      text = "exec ${noctalia} msg ${cmd}";
    };
in
{
  home.packages = [
    (wrap "launcher" "panel-toggle launcher")
    (wrap "power-menu" "panel-toggle session")
    (wrap "control-center-toggle" "panel-toggle control-center")
    (wrap "character-picker" "panel-toggle launcher /emo")
    (wrap "bar-toggle" "bar-toggle")
    (wrap "session-exit" "session logout")
    (wrap "session-lock" "session lock")
    (wrap "session-shutdown" "session shutdown")
    (wrap "session-reboot" "session reboot")
    (pkgs.writeShellApplication {
      name = "wallpaper-picker";
      text = ''
        case "''${1:-}" in
          "") exec ${noctalia} msg panel-toggle wallpaper ;;
          --prev) exec ${noctalia} msg wallpaper-previous ;;
          --next) exec ${noctalia} msg wallpaper-next ;;
          *)
            echo "Usage: wallpaper-picker [--prev|--next]" >&2
            exit 2
            ;;
        esac
      '';
    })
    (pkgs.writeShellApplication {
      name = "clipboard";
      text = ''
        case "''${1:-}" in
          "") exec ${noctalia} msg panel-toggle clipboard ;;
          --wipe) exec ${noctalia} msg clipboard-clear ;;
          *)
            echo "Usage: clipboard [--wipe]" >&2
            exit 2
            ;;
        esac
      '';
    })
    (pkgs.writeShellApplication {
      name = "screenshot";
      text = ''
        case "''${1:-}" in
          # Noctalia has no window-only capture; region selection is the closest equivalent.
          --window | --region) exec ${noctalia} msg screenshot-region ;;
          --output) exec ${noctalia} msg screenshot-fullscreen ;;
          *)
            echo "Usage: screenshot [--window|--region|--output]" >&2
            exit 2
            ;;
        esac
      '';
    })
  ];
}
