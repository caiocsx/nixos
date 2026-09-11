{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "hyprlock-lock-state";
  runtimeInputs = [ pkgs.coreutils ];
  text = ''
    output=""

    check_lock() {
      local type="$1"
      local label="$2"

      for led in /sys/class/leds/input*::"$type"/brightness; do
        if [[ -f "$led" ]] && [[ "$(cat "$led")" == "1" ]]; then
          output+="$label "
          break
        fi
      done
    }

    check_lock "capslock" "Caps 󰪛"
    check_lock "numlock" "Num "

    echo "$output"
  '';
}
