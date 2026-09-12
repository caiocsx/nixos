{ ... }:
{
  den.aspects.quickshell.homeManager =
    {
      config,
      pkgs,
      ui,
      ...
    }:
    let
      clipboardBackend = import ./scripts/_clipboard-backend.nix { inherit config pkgs; };
      clipboardManager = import ./scripts/_clipboard-manager.nix { inherit pkgs; };
    in
    {
      home.packages = [
        clipboardBackend
        clipboardManager
      ];

      programs.quickshell = {
        enable = true;
        configs.default = ./qml;
        activeConfig = "default";
        systemd.enable = true;
      };

      systemd.user.services.quickshell.Service.Environment = [
        "CLIPBOARD_BACKEND=${clipboardBackend}/bin/quickshell-clipboard-backend"
        "QS_BG=${ui.colors.bg}"
        "QS_SURFACE=${ui.colors.surface}"
        "QS_FG=${ui.colors.fg}"
        "QS_MUTED=${ui.colors.muted}"
        "QS_ACCENT=${ui.colors.accent}"
        "QS_RED=${ui.colors.red}"
        "QS_BORDER=${ui.withAlpha ui.colors.accent 0.45}"
        "QS_SELECTED=${ui.withAlpha ui.colors.accent 0.24}"
        "QS_ACTIVE=${ui.withAlpha ui.colors.accent 0.34}"
        "QS_HOVER=${ui.withAlpha ui.colors.accent 0.18}"
        "QS_BUTTON=${ui.withAlpha ui.colors.fg 0.10}"
        "QS_DISABLED=${ui.withAlpha ui.colors.muted 0.60}"
        "QS_OVERLAY=${ui.withAlpha ui.colors.bg 0.70}"
        "QS_FONT=${ui.font.base}"
      ];
    };
}
