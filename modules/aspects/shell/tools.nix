{ ... }:
{
  den.aspects.cli-tools.homeManager =
    { pkgs, ... }:
    {
      home = {
        packages = [
          pkgs.bat
          pkgs.fd
          pkgs.ffmpeg
          pkgs.gnutar
          pkgs.nh
          pkgs.nixfmt
          pkgs.p7zip
          pkgs.ripgrep
          pkgs.tree
          pkgs.unzip
          pkgs.zip
        ];

        sessionVariables.MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      };

      programs.eza = {
        enable = true;
        git = true;
        colors = "always";
        icons = "always";
        extraOptions = [
          "--group-directories-first"
          "--no-quotes"
          "--header"
          "--git-ignore"
          "--time-style=long-iso"
          "--classify"
          "--hyperlink=auto"
        ];
      };

      programs.fzf = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        defaultCommand = "fd --type f";
        defaultOptions = [
          "--height=40%"
          "--layout=reverse"
          "--border"
          "--info=inline"
        ];
        fileWidget = {
          options = [
            "--walker-skip=.git,node_modules,target,dist,.direnv,result"
            "--preview 'bat -n --color=always {} || cat {}'"
            "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
          ];
        };
        historyWidget = {
          options = [
            "--style=full"
          ];
        };
      };

      programs.starship = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        presets = [ "nerd-font-symbols" ];
        settings = {
          battery.disabled = true;
        };
      };

      programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    };
}
