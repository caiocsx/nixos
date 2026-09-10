{ ... }:
{
  den.aspects.waybar.homeManager =
    { pkgs, ui, ... }:
    let
      settings = import ./_settings.nix { inherit ui; };
      style = import ./_style.nix { inherit ui; };
    in
    {
      programs.waybar = {
        enable = true;
        settings = {
          main = settings;
        };
        inherit style;
      };

      systemd.user.services.waybar = {
        Unit = {
          Description = "waybar - Status Bar";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.waybar}/bin/waybar";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
