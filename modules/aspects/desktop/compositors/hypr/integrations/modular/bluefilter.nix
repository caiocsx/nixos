{ ... }:
{
  den.aspects.hyprland-bluefilter.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "bluefilter";
          runtimeInputs = [
            pkgs.procps
            pkgs.systemd
          ];
          text = ''
            readonly WAYBAR_SIGNAL="RTMIN+1"

            print_status() {
              if systemctl --user is-active --quiet hyprsunset.service; then
                printf '󰖔\n'
              else
                printf '󰖙\n'
              fi
            }

            case "''${1:-}" in
              --toggle)
                hyprsunset-toggle
                pkill -"$WAYBAR_SIGNAL" waybar || true
                ;;
              "") print_status ;;
              *) echo "Usage: ''${0##*/} [--toggle]" >&2; exit 1 ;;
            esac
          '';
        })
      ];
    };
}
