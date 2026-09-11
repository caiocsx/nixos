{ ... }:
{
  den.aspects.calculator.homeManager =
    {
      config,
      pkgs,
      ui,
      ...
    }:

    let
      themes = import ../themes/_default.nix { inherit config pkgs ui; };

      qalcFiltered = pkgs.writeShellApplication {
        name = "qalc-filtered";
        runtimeInputs = [
          pkgs.libqalculate
          pkgs.gnugrep
        ];
        text = ''
          qalc "$@" | grep -Ev '^warning: Unknown variables'
        '';
      };

      calculator = pkgs.writeShellApplication {
        name = "calculator";
        runtimeInputs = [
          pkgs.rofi
          pkgs.rofi-calc
        ];
        text = ''
          rofi \
            -show calc \
            -modi calc \
            -plugin-path "${pkgs.rofi-calc}/lib/rofi" \
            -qalc-binary "${qalcFiltered}/bin/qalc-filtered" \
            -theme "${themes.calculator}" \
            -no-show-match \
            -no-sort \
            -calc-command "printf '%s' '{result}' | sed 's/.*= //' | wl-copy" \
            -calc-command-history \
            "$@"
        '';
      };
    in
    {
      home.packages = [
        calculator
      ];
    };
}
