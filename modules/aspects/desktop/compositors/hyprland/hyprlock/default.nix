{ den, ... }:
{
  den.aspects.hyprlock.homeManager =
    { config, pkgs, ui, ... }:
    let
      settings = import ./_settings.nix { inherit config ui; };
      hyprlockMedia = import ./scripts/_hyprlock-media.nix { inherit pkgs; };
      hyprlockLockState = import ./scripts/_hyprlock-lock-state.nix { inherit pkgs; };
      hyprlockSysStatus = import ./scripts/_hyprlock-sys-status.nix { inherit pkgs; };
    in
    {
      home.packages = [
        pkgs.libnotify
        hyprlockMedia
        hyprlockLockState
        hyprlockSysStatus
      ];

      programs.hyprlock = {
        enable = true;
        inherit settings;
      };
    };
}
