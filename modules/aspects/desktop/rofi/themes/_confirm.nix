{ ui, ... }:
let
  theme = import ./_theme.nix { inherit ui; };
in
''
  ${theme}

  window {
    width:            400px;
    border-radius:    @radius;
    background-color: transparent;
  }

  mainbox {
    background-color: transparent;
    children:         [ message, listview ];
  }

  message {
    padding:          20px;
    border-radius:    @radius;
    background-color: @bg;
  }

  textbox {
    vertical-align:   0.5;
    horizontal-align: 0.5;
    font:             "${ui.font.propo} Bold 11";
    text-color:       @fg;
    background-color: transparent;
  }

  listview {
    columns:          2;
    lines:            1;
    cycle:            false;
    padding:          20px;
    spacing:          20px;
    border-radius:    @radius;
    background-color: @surface;
  }

  element {
    padding:          10px 5px;
    cursor:           pointer;
    border-radius:    @radius;
    text-color:       @fg;
    background-color: @bg;
  }

  element-text {
    vertical-align:   0.5;
    horizontal-align: 0.5;
    cursor:           inherit;
    font:             "${ui.font.propo} Bold 28";
    text-color:       inherit;
    background-color: transparent;
  }
''
