{ ... }:
{
  den.aspects.hyprsunset.homeManager =
    { config, lib, pkgs, ... }:
    let
      hyprsunsetToggle = import ./scripts/_hyprsunset-toggle.nix { inherit pkgs; };
    in
    {
      imports = [ ./_services.nix ];

      options.hyprsunset.temperature = lib.mkOption {
        type = lib.types.ints.between 1000 10000;
        default = 4800;
        description = "Color temperature (Kelvin) used by hyprsunset.";
      };

      config = {
        home.packages = [
          pkgs.hyprsunset
          hyprsunsetToggle
        ];
      };
    };
}
