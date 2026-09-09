{ ... }:
{
  den.aspects.launcher.homeManager =
    {
      config,
      pkgs,
      ui,
      ...
    }:

    let
      themes = import ../themes/_default.nix { inherit config pkgs ui; };

      launcher = pkgs.writeShellApplication {
        name = "launcher";
        runtimeInputs = with pkgs; [
          rofi
        ];
        text = ''
          rofi -show drun -theme ${themes.launcher}
        '';
      };
    in
    {
      home.packages = [
        launcher
      ];
    };
}
