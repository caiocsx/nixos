{ inputs, ... }:
{
  den.aspects.nixpkgs.nixos = { ... }: {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [ inputs.nix-vscode-extensions.overlays.default ];
    };
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
  };
}
