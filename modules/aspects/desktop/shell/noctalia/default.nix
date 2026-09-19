{ inputs, ... }:
{
  den.aspects.noctalia.homeManager =
    { config, ... }:
    {
      imports = [
        inputs.noctalia.homeModules.default
        ./_commands.nix
        ./_contract.nix
      ];

      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        settings = import ./_settings.nix {
          inherit config;
          nixLogo = ../../../../../assets/nixos-white.png;
        };
      };

    };
}
