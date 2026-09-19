{ lib }:
let
  lua = lib.generators.mkLuaInline;
  bind = keys: description: command: {
    _args = [
      keys
      (lua ''hl.dsp.exec_cmd("${command}")'')
      { inherit description; }
    ];
  };
in
[
  (bind "SUPER + TAB" "Open window switcher" "window-switcher")
  (bind "SUPER + COMMA" "Open shell settings" "shell-settings")
]
