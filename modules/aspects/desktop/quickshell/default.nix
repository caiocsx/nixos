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
      theme = import ./_theme.nix { inherit pkgs ui; };
      quickshellConfig = pkgs.runCommandLocal "quickshell-config" { } ''
        cp -r ${./qml} "$out"
        chmod -R u+w "$out"
        cp ${theme} "$out/clipboard/Theme.qml"
      '';
    in
    {
      home.packages = [
        clipboardBackend
        clipboardManager
      ];

      programs.quickshell = {
        enable = true;
        configs.default = quickshellConfig;
        activeConfig = "default";
        systemd.enable = true;
      };

      systemd.user.services.quickshell.Service.Environment = [
        "CLIPBOARD_BACKEND=${clipboardBackend}/bin/quickshell-clipboard-backend"
      ];
    };
}
