{ ui, ... }:
let
  theme = import ./_theme.nix { inherit ui; };
in
''
  ${theme}

  configuration {
    font:              "${ui.font.propo} 10";
  }

  window {
    width:             480px;
    padding:           10px;
    border-radius:     @radius;
    background-color:  @bg;
  }

  mainbox {
    background-color:  transparent;
    children:          [ inputbar ];
  }

  inputbar {
    padding:           12px;
    spacing:           15px;
    border-radius:     @radius;
    background-color:  @surface;
    children:          [ textbox-prompt-colon, entry ];
  }

  textbox-prompt-colon {
    str:               "󰌾";
    expand:            false;
    text-color:        @fg;
    background-color:  transparent;
  }

  entry {
    placeholder:       "Password...";
    placeholder-color: @muted;
    vertical-align:    0.5;
    cursor:            text;
    text-color:        @fg;
    background-color:  transparent;
  }
''
