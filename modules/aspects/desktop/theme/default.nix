{ inputs, ... }:
{
  den.aspects.theme = {
    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.stylix.nixosModules.stylix ];

        stylix = {
          enable = true;
          polarity = "dark";
          base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
          image = ../../../../assets/wallpapers/porsche.jpg;
          cursor = {
            name = "Bibata-Modern-Ice";
            package = pkgs.bibata-cursors;
            size = 20;
          };
          icons = {
            enable = true;
            package = pkgs.papirus-icon-theme;
            dark = "Papirus-Dark";
          };
          fonts = {
            sizes = {
              applications = 11;
              desktop = 11;
              popups = 11;
              terminal = 11;
            };
            serif = {
              package = pkgs.noto-fonts;
              name = "Noto Serif";
            };
            sansSerif = {
              package = pkgs.inter;
              name = "Inter";
            };
            monospace = {
              package = pkgs.nerd-fonts.jetbrains-mono;
              name = "JetBrainsMono Nerd Font";
            };
            emoji = {
              package = pkgs.noto-fonts-color-emoji;
              name = "Noto Color Emoji";
            };
          };
          targets.grub.enable = false;
        };
      };

    homeManager =
      { config, lib, ... }:
      {
        _module.args.ui = import ./_ui.nix {
          inherit config lib;
        };

        home.pointerCursor.enable = true;
        stylix.targets = {
          hyprland.enable = false;
          hyprlock.enable = false;
          rofi.enable = false;
          swaync.enable = false;
          waybar.enable = false;

          zen-browser.profileNames = [ "default" ];
        };

        xdg.dataFile = {
          "applications/qt5ct.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Name=Qt5 Configuration
            Exec=true
            NoDisplay=true
          '';
          "applications/qt6ct.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Name=Qt6 Configuration
            Exec=true
            NoDisplay=true
          '';
          "applications/kvantummanager.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Name=Kvantum Manager
            Exec=true
            NoDisplay=true
          '';
        };
      };
  };
}
