{ den, ... }:
{
  den.aspects.pad = {
    includes = [
      den.aspects.ly
      # den.aspects.sddm
      # den.aspects.libvirt
      # den.aspects.ollama
      # den.aspects.gaming
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [ ./_hardware-configuration.nix ];

        boot = {
          kernelParams = [
            "radeon.si_support=0"
            "amdgpu.si_support=1"
          ];

          # --- NixOS system overrides (uncomment to customize) ---
          # kernelPackages = pkgs.linuxPackages;  # Default: linuxPackages_zen

          # loader = {
          # timeout = 10;                       # Default: 30
          # grub.useOSProber = false;           # Default: true
          # };
        };
        hardware = {
          graphics = {
            enable = true;
            extraPackages = [
              pkgs.libva
              pkgs.libva-utils
              pkgs.libvdpau-va-gl
            ];
          };
        };
        services = {
          xserver = {
            videoDrivers = [ "amdgpu" ];
            xkb = {
              layout = "br";
              variant = "";
            };
          };

          # --- Optional aspect overrides (uncomment to customize) ---
          # displayManager = {
          # ly.animation = "doom";                 # Default: "matrix"
          # sddm.astronaut.theme = "cyberpunk";    # Default: "pixel_sakura"
          # };

          power-profiles-daemon.enable = true;
        };

        # --- System locale & user overrides ---
        # time.timeZone = "America/Sao_Paulo";       # Default: "America/Recife"
        # i18n.defaultLocale = "pt_BR.UTF-8";        # Default: "en_US.UTF-8"
        # documentation.nixos.enable = true;         # Default: false
      };

    provides.to-users.homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.brightnessctl ];

        wayland.windowManager.hyprland.settings = {
          monitor = [
            {
              output = "eDP-1";
              mode = "1920x1080@60";
              position = "0x0";
              scale = "1.0";
            }
          ];

          config.input = {
            kb_layout = "br";
            kb_variant = "";

            touchpad = {
              natural_scroll = false;
              disable_while_typing = true;
            };
          };
        };

        # --- Optional Home Manager aspect overrides (uncomment to customize) ---
        # hyprsunset.temperature = 4200;           # Default: 4800
        # clipboard.maxItems = 1000;               # Default: 750
      };
  };
}
