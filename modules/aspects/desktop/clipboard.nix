{ ... }:
{
  den.aspects.clipboard.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cliphistStore = import ./_cliphist-store.nix { inherit config pkgs; };
    in
    {
      options.clipboard.maxItems = lib.mkOption {
        type = lib.types.int;
        default = 750;
        description = "Maximum number of items saved in the cliphist history.";
      };

      config = {
        home.packages = [
          pkgs.cliphist
          pkgs.wl-clipboard
        ];

        systemd.user.services.cliphist = {
          Unit = {
            Description = "cliphist - Clipboard manager";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${cliphistStore}/bin/cliphist-store";
            Restart = "on-failure";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
