{ config, pkgs, ... }:
let
  cfg = config.hyprsunset;
  hyprsunsetRestore = import ./scripts/_hyprsunset-restore.nix { inherit pkgs; };
in
{
  systemd.user.services = {
    hyprsunset = {
      Unit = {
        Description = "hyprsunset - Blue-light Filter";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.hyprsunset}/bin/hyprsunset -t ${toString cfg.temperature}";
        Restart = "on-failure";
      };
    };

    hyprsunset-restore = {
      Unit = {
        Description = "Restores the hyprsunset state from the previous session";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${hyprsunsetRestore}/bin/hyprsunset-restore";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
