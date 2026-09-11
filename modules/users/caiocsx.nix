{ den, ... }:
{
  den.aspects.caiocsx = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")

      den.aspects.desktop

      den.aspects.zsh
      den.aspects.cli-tools
      den.aspects.git
      den.aspects.btop
      den.aspects.fastfetch
      den.aspects.direnv
      den.aspects.docker
      den.aspects.flatpak

      den.aspects.kitty
      den.aspects.thunar
      den.aspects.vscodium
      den.aspects.imv
      den.aspects.mpv
      den.aspects.qbittorrent
      den.aspects.spicetify
      den.aspects.discord
      den.aspects.zen-browser
    ];

    user =
      { ... }:
      {
        extraGroups = [
          "docker"
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.proton-vpn
          pkgs.proton-pass
          pkgs.protonmail-desktop
          # gimp
          pkgs.libresprite
          pkgs.opencode
          pkgs.obsidian
          pkgs.godot
          # bruno
          pkgs.onlyoffice-desktopeditors
        ];

        programs.git = {
          settings = {
            user = {
              name = "caiocsx";
              email = "caiocesarsts@gmail.com";
            };
          };
        };
      };
  };
}
