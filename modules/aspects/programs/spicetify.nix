{ inputs, ... }:
{
  den.aspects.spicetify.homeManager =
    { pkgs, ... }:
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [
        inputs.spicetify-nix.homeManagerModules.default
      ];

      programs.spicetify = {
        enable = true;
        enabledExtensions = [
          spicePkgs.extensions.adblock
          spicePkgs.extensions.hidePodcasts
          spicePkgs.extensions.shuffle
        ];
      };
    };
}
