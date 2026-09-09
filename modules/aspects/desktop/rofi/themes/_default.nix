{ config, pkgs, ui, ... }:
{
  confirm = pkgs.writeText "confirm.rasi" (
    import ./_confirm.nix { inherit ui; }
  );

  password = pkgs.writeText "password.rasi" (
    import ./_password.nix { inherit ui; }
  );

  listMenu = pkgs.writeText "list-menu.rasi" (
    import ./_list-menu.nix { inherit ui; }
  );

  powerMenu = pkgs.writeText "power-menu.rasi" (
    import ./_power-menu.nix { inherit config ui; }
  );

  launcher = pkgs.writeText "launcher.rasi" (
    import ./_launcher.nix { inherit config ui; }
  );

  characterPicker = pkgs.writeText "character-picker.rasi" (
    import ./_character-picker.nix { inherit ui; }
  );

  calculator = pkgs.writeText "calculator.rasi" (
    import ./_calculator.nix { inherit ui; }
  );

  wallpaperPicker = pkgs.writeText "wallpaper-picker.rasi" (
    import ./_wallpaper-picker.nix { inherit ui; }
  );
}
