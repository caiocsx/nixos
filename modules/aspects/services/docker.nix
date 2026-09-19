{ ... }:
{
  den.aspects.docker = {
    nixos =
      { ... }:
      {
        virtualisation.docker.enable = true;
      };

    user =
      { ... }:
      {
        extraGroups = [
          "docker"
        ];
      };
  };
}
