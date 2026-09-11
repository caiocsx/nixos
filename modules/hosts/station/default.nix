{ den, ... }:
{
  den.aspects.station = {
    includes = [
      den.aspects.ly
      # den.aspects.sddm
      # den.aspects.libvirt
      den.aspects.ollama
      den.aspects.gaming
    ];

    nixos =
      { config, pkgs, ... }:
      {
        imports = [ ./_hardware-configuration.nix ];

        boot = {
          kernelModules = [
            "nvidia"
            "nvidia_modeset"
            "nvidia_uvm"
            "nvidia_drm"
          ];
          kernelParams = [
            "nvidia-drm.modeset=1"
            "nvidia_drm.fbdev=1"
          ];

          # --- NixOS system overrides (uncomment to customize) ---
          # kernelPackages = pkgs.linuxPackages;  # Default: linuxPackages_zen

          # loader = {
          # timeout = 10;                       # Default: 30
          # grub.useOSProber = false;           # Default: true
          # };
        };
        hardware = {
          nvidia = {
            open = true;
            modesetting.enable = true;
            powerManagement.enable = true;
            nvidiaSettings = false;
            package = config.boot.kernelPackages.nvidiaPackages.latest;
          };
          graphics = {
            enable = true;
            extraPackages = [
              pkgs.nvidia-vaapi-driver
              pkgs.libva-vdpau-driver
              pkgs.libvdpau-va-gl
            ];
          };
        };
        services = {
          xserver = {
            videoDrivers = [ "nvidia" ];

            xkb = {
              layout = "us";
              variant = "intl";
            };
          };

          # --- Optional aspect overrides (uncomment to customize) ---
          # displayManager = {
          # ly.animation = "doom";                 # Default: "matrix"
          # sddm.astronaut.theme = "cyberpunk";    # Default: "pixel_sakura"
          # };

          ollama = {
            package = pkgs.ollama-cuda;
            # contextLength = 65536;                 # Default: 32768
          };
        };

        # --- System locale & user overrides ---
        # time.timeZone = "America/Sao_Paulo";       # Default: "America/Recife"
        # i18n.defaultLocale = "pt_BR.UTF-8";        # Default: "en_US.UTF-8"
        # documentation.nixos.enable = true;         # Default: false

        # users.users.caiocsx.extraGroups = [ "libvirtd" ];
      };

    provides.to-users.homeManager =
      { lib, pkgs, ... }:
      {
        wayland.windowManager.hyprland = {
          extraConfig = lib.mkAfter ''
            -- --- Nvidia Env Vars ---
            hl.env("GBM_BACKEND", "nvidia-drm")
            hl.env("LIBVA_DRIVER_NAME", "nvidia")
            hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
            hl.env("__GL_GSYNC_ALLOWED", "1")
            hl.env("__GL_VRR_ALLOWED", "1")
            hl.env("__GL_MaxFramesAllowed", "1")
          '';

          settings = {
            monitor = [
              {
                output = "HDMI-A-1";
                mode = "1920x1080@180";
                position = "0x0";
                scale = "1.0";
              }
            ];

            config.input = {
              kb_layout = "us";
              kb_variant = "intl";
            };
          };
        };

        # --- Optional Home Manager aspect overrides (uncomment to customize) ---
        # hyprsunset.temperature = 4200;           # Default: 4800
        # clipboard.maxItems = 1000;               # Default: 750
      };
  };
}
