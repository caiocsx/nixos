{ ... }:
{
  den.aspects.screenshot.homeManager = { config, pkgs, ... }: {
    home.packages = [ (import ./scripts/_screenshot.nix { inherit pkgs; }) ];

    xdg.configFile."swappy/config".text = ''
      [Default]
      save_dir=${config.home.homeDirectory}/Pictures/Screenshots
      save_filename_format=%Y-%m-%d_%H-%M-%S.png
    '';
  };
}
