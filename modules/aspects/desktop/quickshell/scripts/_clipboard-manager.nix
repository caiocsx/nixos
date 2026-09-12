{ pkgs }:
pkgs.writeShellApplication {
  name = "clipboard-manager";
  runtimeInputs = [ pkgs.quickshell ];
  text = ''
    case "''${1-}" in
      ""|-c|--history) mode=history ;;
      -f|--favorites) mode=favorites ;;
      -h|--help)
        echo "Usage: ''${0##*/} [-c|--history | -f|--favorites | -h|--help]"
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
    esac

    qs ipc call -- clipboard show "$mode"
  '';
}
