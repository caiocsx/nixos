{ den, ... }:
{
  den.aspects.hyprshutdown.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "session-exit";
          runtimeInputs = [ pkgs.hyprshutdown ];
          text = "exec hyprshutdown";
        })
        (pkgs.writeShellApplication {
          name = "session-shutdown";
          runtimeInputs = [ pkgs.hyprshutdown ];
          text = "exec hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'";
        })
        (pkgs.writeShellApplication {
          name = "session-reboot";
          runtimeInputs = [ pkgs.hyprshutdown ];
          text = "exec hyprshutdown -t 'Restarting...' --post-cmd reboot";
        })
      ];
    };
}
