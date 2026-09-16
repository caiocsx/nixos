{ ui, ... }:
let
  theme = import ./_theme.nix { inherit ui; };
in
''
  ${theme}

  configuration {
    font:               "${ui.font.propo} 10";
    show-icons:         true;
  }

  window {
    width:              620px;
    height:             560px;
    padding:            10px;
    border-radius:      @radius;
    background-color:   @bg;
  }

  mainbox {
    orientation:        vertical;
    spacing:            20px;
    background-color:   transparent;
    children:           [ inputbar, listbox ];
  }

  inputbar {
    padding:            12px;
    spacing:            15px;
    border-radius:      @radius;
    background-color:   @surface;
    children:           [ textbox-prompt-colon, entry ];
  }

  textbox-prompt-colon {
    vertical-align:     0.5;
    str:                "󰞅";
    font:               "${ui.font.propo} 12";
    text-color:         @fg;
    expand:             false;
    background-color:   transparent;
  }

  entry {
    vertical-align:     0.5;
    placeholder:        "Search characters...";
    placeholder-color:  @muted;
    cursor:             text;
    text-color:         @fg;
    background-color:   transparent;
  }

  listbox {
    background-color:   transparent;
    children:           [ listview ];
  }

  listview {
    columns:            7;
    lines:              6;
    spacing:            8px;
    cycle:              true;
    dynamic:            true;
    layout:             vertical;
    flow:               horizontal;
    reverse:            false;
    scrollbar:          true;
    fixed-height:       true;
    fixed-columns:      true;
    background-color:   transparent;
  }

  element {
    orientation:        vertical;
    padding:            12px;
    cursor:             pointer;
    border-radius:      @radius;
    background-color:   transparent;
  }

  element-icon {
    size:               48px;
    horizontal-align:   0.5;
    vertical-align:     0.5;
    cursor:             inherit;
    background-color:   transparent;
  }

  element-text {
    enabled:            false;
  }
''
