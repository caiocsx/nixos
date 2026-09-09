{ ... }:
{
  den.aspects.zsh = {
    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      {
        programs.zsh = {
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          dotDir = "${config.xdg.configHome}/zsh";
          history = {
            size = 10000;
            save = 10000;
            ignoreAllDups = true;
            ignoreDups = true;
            ignoreSpace = true;
            path = "${config.xdg.cacheHome}/zsh/history";
          };
          initContent = ''
            export YSU_IGNORED_ALIASES=("ls" "eza")
            
            setopt share_history
            setopt correct

            zstyle ':fzf-tab:*' use-fzf-default-opts yes
            zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath'
          '';
          shellAliases = {
            c = "clear";
            h = "history";
            ff = "fastfetch";
            lse = "eza --no-filesize --no-time --no-user --no-permissions";
            ll = "eza -lh";
            la = "eza -a";
            lah = "eza -lah";
            lt = "eza -aT";
            nck = "nix flake check";
            nwt = "nix run .#write-flake";
            ncl = "nh clean all";
            nrs = "nh os switch ~/nixos";
            nup = "nix flake update --flake ~/nixos";
            nupg = "nix flake update --flake ~/nixos && nh os switch ~/nixos";
          };
          plugins = [
            {
              name = "fzf-tab";
              src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
              file = "fzf-tab.plugin.zsh";
            }
            {
              name = "you-should-use";
              src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
              file = "you-should-use.plugin.zsh";
            }
            {
              name = "autopair";
              src = "${pkgs.zsh-autopair}/share/zsh/zsh-autopair";
              file = "autopair.zsh";
            }
          ];
        };
      };
  };
}
