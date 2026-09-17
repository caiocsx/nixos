{ ... }:
{
  den.aspects.character-picker.homeManager =
    {
      config,
      pkgs,
      ui,
      ...
    }:

    let
      themes = import ../themes/_default.nix { inherit config pkgs ui; };

      characterPicker = pkgs.writeShellApplication {
        name = "character-picker";
        runtimeInputs = [
          pkgs.rofi
          pkgs.rofimoji
          pkgs.wl-clipboard
          pkgs.wtype
        ];
        text = ''
          rofi -modi "emoji:rofimoji --action copy --use-icons --hidden-descriptions
          --files emojis nerd_font math latin-1_supplement" \
          -kb-row-left Left \
          -kb-row-right Right \
          -kb-move-char-back Control+b \
          -kb-move-char-forward Control+f \
          -show emoji \
          -theme "${themes.characterPicker}"
        '';
      };
    in
    {
      home.packages = [
        characterPicker
      ];
    };
}
