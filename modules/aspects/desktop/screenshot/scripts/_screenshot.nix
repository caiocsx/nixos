{ pkgs }:

pkgs.writeShellApplication {
  name = "screenshot";

  runtimeInputs = [
    pkgs.grim
    pkgs.hyprland
    pkgs.jq
    pkgs.slurp
    pkgs.swappy
  ];

  text = ''
    select_region() {
      slurp
    }

    select_window() {
      hyprctl clients -j |
        jq -r '
          .[]
          | select(.workspace.id >= 0)
          | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"
        ' | slurp
    }

    select_output() {
      slurp -o
    }

    main() {
      local geometry

      case "''${1-}" in
        ""|-r|--region)
          geometry="$(select_region)"
          ;;
        -w|--window)
          geometry="$(select_window)"
          ;;
        -o|--output)
          geometry="$(select_output)"
          ;;
        -h|--help)
          echo "Usage: ''${0##*/} [-w|--window | -r|--region | -o|--output | -h|--help]"
          exit 0
          ;;
        *)
          echo "Unknown option: $1" >&2
          exit 1
          ;;
      esac

      [[ -n "$geometry" ]] || exit 0

      grim -g "$geometry" - |
        swappy -f -
    }

    main "$@"
  '';
}
