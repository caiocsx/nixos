{ ... }:

{
  den.aspects.vscodium.homeManager =
    { pkgs, ui, ... }:

    let
      extensions = [
        pkgs.vscode-marketplace.pkief.material-icon-theme
        pkgs.vscode-marketplace.mkhl.direnv
        pkgs.vscode-marketplace.jnoortheen.nix-ide
      ];

      commonSettings = {
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.startupEditor" = "none";
        "workbench.layoutControl.enabled" = false;
        "workbench.editor.labelFormat" = "short";
        "window.titleBarStyle" = "native";
        "window.customTitleBarVisibility" = "never";
        "window.menuBarVisibility" = "hidden";
        "breadcrumbs.enabled" = false;
        "workbench.list.smoothScrolling" = true;

        "workbench.colorCustomizations" = {
          "editor.background" = ui.colors.surface;
          "editorGutter.background" = ui.colors.surface;
          "editor.lineHighlightBackground" = ui.colors.accent;

          "panel.background" = ui.colors.surface;
          "terminal.background" = ui.colors.surface;

          "sideBar.background" = ui.colors.bg;
          "sideBarSectionHeader.background" = ui.colors.bg;
          "activityBar.background" = ui.colors.bg;
          "editorGroupHeader.tabsBackground" = ui.colors.bg;
          "statusBar.background" = ui.colors.bg;

          "tab.inactiveBackground" = ui.colors.bg;
          "tab.activeBackground" = ui.colors.surface;

          "input.background" = ui.colors.surface;
          "input.border" = ui.colors.accent;
        };

        "editor.lineHeight" = 1.8;
        "editor.fontLigatures" = true;
        "editor.padding.top" = 20;
        "editor.padding.bottom" = 20;
        "editor.cursorBlinking" = "smooth";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.smoothScrolling" = true;
        "editor.scrollbar.horizontal" = "hidden";
        "editor.minimap.enabled" = false;
        "editor.stickyScroll.enabled" = false;
        "editor.renderLineHighlight" = "gutter";
        "editor.guides.bracketPairs" = true;
        "editor.rulers" = [ 120 ];

        "editor.tabSize" = 2;
        "editor.tabCompletion" = "on";
        "editor.wordWrap" = "wordWrapColumn";
        "editor.wordWrapColumn" = 100;
        "editor.linkedEditing" = true;
        "editor.inlineSuggest.enabled" = true;
        "editor.formatOnSave" = true;
        "editor.formatOnPaste" = false;
        "editor.codeActionsOnSave" = {
          "source.fixAll.eslint" = "explicit";
          "source.organizeImports" = "explicit";
        };

        "files.autoSave" = "afterDelay";
        "files.eol" = "\n";
        "files.insertFinalNewline" = true;
        "files.trimTrailingWhitespace" = true;
        "files.exclude" = {
          "/.git" = true;
          "/.DS_Store" = true;
        };
        "explorer.compactFolders" = false;
        "explorer.sortOrder" = "foldersNestsFiles";
        "workbench.tree.indent" = 15;
        "workbench.tree.renderIndentGuides" = "none";

        "explorer.fileNesting.enabled" = true;
        "explorer.fileNesting.patterns" = {
          "package.json" = "package-lock.json; yarn.lock; pnpm-lock.yaml; bun*";
          "tsconfig.json" = "tsconfig..json";
          ".env" = ".env.; .local";
          "jest.config." = "jest.config.; jest.setup.; jest..config";
          "vitest.config." = "vitest.config.; vitest.setup.";
          "Dockerfile" = "Dockerfile.; .dockerignore; docker-compose.";
          ".gitignore" = ".gitattributes; .gitmodules";
        };

        "terminal.integrated.fontFamily" = "${ui.font.mono}";
        "terminal.integrated.fontLigatures.enabled" = true;
        "terminal.integrated.cursorBlinking" = true;
        "terminal.integrated.stickyScroll.enabled" = false;

        "git.autofetch" = true;
        "diffEditor.ignoreTrimWhitespace" = true;

        "extensions.ignoreRecommendations" = true;
      };
    in
    {
      programs.vscodium = {
        enable = true;
        profiles = {
          default = {
            inherit extensions;
            userSettings = commonSettings;
          };
        };
      };

      home.sessionVariables.EDITOR = "codium";

      xdg.mimeApps.defaultApplications = {
        "text/plain" = "codium.desktop";
        "text/markdown" = "codium.desktop";
        "application/json" = "codium.desktop";
        "text/css" = "codium.desktop";
        "text/html" = "codium.desktop";
      };
    };
}
