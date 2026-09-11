{ ... }:
{
  den.aspects.audio = {
    nixos =
      { ... }:
      {
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
        };
        security.rtkit.enable = true;
      };

    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.pavucontrol
        pkgs.playerctl
      ];
    };
  };
}
