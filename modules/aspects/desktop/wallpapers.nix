{ ... }:
{
  den.aspects.wallpapers.homeManager = { pkgs, ... }: {
    home = {
      packages = with pkgs; [ awww ];

      file."Pictures/Wallpapers" = {
        source = ../../../assets/wallpapers;
        recursive = true;
      };
    };

    systemd.user.services.awww-daemon = {
      Unit = {
        Description = "awww - Wallpaper daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session-pre.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.awww}/bin/awww-daemon";
        Restart = "on-failure";
        RestartSec = 1;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
