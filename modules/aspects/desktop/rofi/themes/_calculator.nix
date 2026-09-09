{ ui, ... }:
let
  theme = import ./_theme.nix { inherit ui; };
in
''
  ${theme}

  configuration {
    font:               "${ui.font.propo} 10";
    calc {
      hint-result:      "= ";
      hint-welcome:     "Calc";
    }
  }

  window {
    width:              520px;
    height:             480px;
    padding:            10px;
    border-radius:      @radius;
    background-color:   @bg;
  }

  mainbox {
    orientation:        vertical;
    spacing:            15px;
    background-color:   transparent;
    children:           [ inputbar, message, listbox ];
  }

  inputbar {
    padding:            12px;
    spacing:            15px;
    border-radius:      @radius;
    background-color:   @surface;
    children:           [ textbox-prompt-colon, entry ];
  }

  textbox-prompt-colon {
    str:                "";
    text-color:         @fg;
    expand:             false;
    background-color:   transparent;
  }

  entry {
    placeholder:        "Type an expression...";
    placeholder-color:  @muted;
    cursor:             text;
    text-color:         @fg;
    background-color:   transparent;
  }

  message {
    padding:            12px 15px;
    border-radius:      @radius;
    background-color:   @surface;
  }

  textbox {
    text-color:         @fg;
    background-color:   transparent;
  }

  error-message {
    padding:            12px 15px;
    border-radius:      @radius;
    background-color:   @surface;
    text-color:        #e06c75;
  }

  listbox {
    background-color:   transparent;
    children:           [ listview ];
  }

  listview {
    spacing:            8px;
    columns:            1;
    scrollbar:          true;
    cycle:              true;
    dynamic:            true;
    fixed-height:       true;
    fixed-columns:      true;
    background-color:   transparent;
  }

  element {
    padding:            12px 15px;
    cursor:             pointer;
    border-radius:      @radius;
    text-color:         @fg;
    background-color:   transparent;
  }

  element-text {
    vertical-align:     0.5;
    cursor:             inherit;
    text-color:         inherit;
    background-color:   transparent;
  }
''
