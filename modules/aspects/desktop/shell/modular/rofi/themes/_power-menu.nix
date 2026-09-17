{ config, ui, ... }:
let
  theme = import ./_theme.nix { inherit ui; };
in
''
  ${theme}

  configuration {
    font:                   "${ui.font.propo} 10";
  }

  window {
    width:                  860px;
    padding:                10px;
    border-radius:          @radius;
    background-color:       @bg;
  }

  mainbox {
    background-color:       transparent;
    children:               [ inputbar, listview, message ];
  }

  inputbar {
    padding:                100px 80px;
    border-radius:          @radius;
    background-image:       url("${config.xdg.cacheHome}/wallpapers/current", width);
    children:               [ textbox-prompt-colon, dummy, prompt ];
  }

  textbox-prompt-colon {
    str:                    " System";
    expand:                 false;
    padding:                12px;
    border-radius:          @radius;
    text-color:             @fg;
    background-color:       @bg;
  }

  dummy {
    expand:              true;
    background-color:    transparent;
  }

  prompt {
    padding:                12px;
    border-radius:          @radius;
    text-color:             @fg;
    background-color:       @bg;
  }

  listview {
    columns:                6;
    lines:                  1;
    cycle:                  true;
    dynamic:                true;
    layout:                 vertical;
    fixed-height:           true;
    fixed-columns:          true;
    spacing:                15px;
    margin:                 15px 0;
    background-color:       transparent;
  }

  element {
    padding:                30px 10px;
    cursor:                 pointer;
    border-radius:          @radius;
    text-color:             @fg;
    background-color:       @surface-solid;
  }

  element-text {
    vertical-align:         0.5;
    horizontal-align:       0.5;
    cursor:                 inherit;
    font:                   "${ui.font.propo} 32";
    text-color:             inherit;
    background-color:       transparent;
  }

  message {
    padding:                20px;
    border-radius:          @radius;
    text-color:             @fg;
    background-color:       @surface-solid;
  }

  textbox {
    vertical-align:         0.5;
    horizontal-align:       0.5;
    text-color:             inherit;
    background-color:       inherit;
  }
''
