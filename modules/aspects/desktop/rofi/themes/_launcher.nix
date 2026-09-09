{ config, ui, ... }:
let
  theme = import ./_theme.nix { inherit ui; };
in
''
  ${theme}

  configuration {
    modi:                "drun,filebrowser,window,run";
    show-icons:          true;
    drun-display-format: "{name}";
    display-drun:        " ";
    display-filebrowser: " ";
    display-window:      " ";
    display-run:         " ";
    font:                "${ui.font.propo} 10";
    icon-theme:          "PapirusDark";
  }

  window {
    width:               980px;
    height:              560px;
    padding:             10px;
    border-radius:       @radius;
    background-color:    @bg;
  }

  mainbox {
    orientation:         horizontal;
    background-color:    transparent;
    children:            [ imagebox, listview ];
  }

  imagebox {
    orientation:         vertical;
    border-radius:       @radius;
    background-image:    url("${config.xdg.cacheHome}/wallpapers/current", height);
    children:            [ inputbar, dummy, mode-switcher ];
  }

  inputbar {
    margin:              20px;
    padding:             15px;
    spacing:             15px;
    border-radius:       @radius;
    background-color:    @surface;
    children:            [ textbox-prompt-colon, entry ];
  }

  textbox-prompt-colon {
    str:                 "";
    text-color:          @fg;
    expand:              false;
    background-color:    transparent;
  }

  entry {
    placeholder:         "Search";
    placeholder-color:   @muted;
    text-color:          @fg;
    cursor:              text;
    background-color:    transparent;
  }

  dummy {
    expand:              true;
    background-color:    transparent;
  }

  mode-switcher {
    padding:             20px;
    spacing:             10px;
    orientation:         horizontal;
    background-color:    transparent;
  }

  button {
    padding:             12px;
    cursor:              pointer;
    border-radius:       @radius;
    text-color:          @fg;
    background-color:    @surface;
  }

  listview {
    columns:             1;
    cycle:               true;
    flow:                horizontal;
    spacing:             5px;
    padding:             10px 20px;
    background-color:    transparent;
  }

  element {
    orientation:         horizontal;
    padding:             10px 15px;
    spacing:             15px;
    cursor:              pointer;
    border-radius:       40px;
    text-color:          @fg;
    background-color:    transparent;
  }

  element-icon {
    size:                40px;
    cursor:              inherit;
    background-color:    transparent;
  }

  element-text {
    horizontal-align:    0.0;
    vertical-align:      0.5;
    cursor:              inherit;
    text-color:          inherit;
    background-color:    transparent;
  }
''
