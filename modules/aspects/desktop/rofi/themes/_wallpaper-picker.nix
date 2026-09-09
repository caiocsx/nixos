{ ui, ... }:
let
  theme = import ./_theme.nix { inherit ui; };
in
''
  ${theme}

  configuration {
    font:              "${ui.font.propo} 10";
    show-icons:        true;
  }

  window {
    width:             820px;
    height:            700px;
    padding:           20px;
    border-radius:     @radius;
    background-color:  @bg;
  }

  mainbox {
    spacing:           20px;
    orientation:       vertical;
    background-color:  transparent;
    children:          [ inputbar, listview ];
  }

  inputbar {
    padding:           12px;
    spacing:           15px;
    border-radius:     @radius;
    background-color:  @surface;
    children:          [ textbox-prompt-colon, entry ];
  }

  textbox-prompt-colon {
    str:               "";
    text-color:        @fg;
    expand:            false;
    background-color:  transparent;
  }

  entry {
    placeholder:       "Search wallpaper...";
    placeholder-color: @muted;
    text-color:        @fg;
    cursor:            text;
    background-color:  transparent;
  }

  listview {
    columns:           3;
    lines:             2;
    scrollbar:         true;
    cycle:             false;
    flow:              horizontal;
    fixed-width:       true;
    fixed-height:      true;
    spacing:           12px;
    background-color:  transparent;
  }

  element {
    orientation:       vertical;
    padding:           5px;
    spacing:           5px;
    cursor:            pointer;
    border-radius:     @radius;
    text-color:        @fg;
    background-color:  @surface-solid;
  }

  element-icon {
    horizontal-align:  0.5;
    vertical-align:    0.5;
    size:              250px;
    cursor:            inherit;
    border-radius:     @radius;
  }

  element-text {
    horizontal-align:  0.5;
    cursor:            inherit;
    text-color:        inherit;
    background-color:  transparent;
  }
''
