{ den, ... }:
{
  den.aspects.swaync.homeManager =
    { pkgs, ui, ... }:
    let
      settings = import ./_settings.nix { };
      style = import ./_style.nix { inherit ui; };
    in
    {
      imports = [ ./_contract.nix ];

      home.packages = [ pkgs.libnotify ];

      services.swaync = {
        enable = true;
        inherit settings style;
      };
    };
}
