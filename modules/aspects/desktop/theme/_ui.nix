{ config, lib, ... }:
let
  f = config.stylix.fonts;

  cHashtag = config.lib.stylix.colors.withHashtag;

  baseColors = {
    bg = cHashtag.base00;
    surface = cHashtag.base01;
    fg = cHashtag.base05;
    muted = cHashtag.base04;
    cyan = cHashtag.base0C;
    blue = cHashtag.base0D;
    green = cHashtag.base0B;
    magenta = cHashtag.base0F;
    orange = cHashtag.base09;
    purple = cHashtag.base0E;
    red = cHashtag.base08;
    yellow = cHashtag.base0A;
  };
  currentAccent = baseColors.blue;

  stripHash = color: lib.strings.removePrefix "#" color;

  toHex2 =
    opacity:
    let
      hex = lib.toHexString (builtins.floor (opacity * 255));
    in
    if builtins.stringLength hex == 1 then "0${hex}" else hex;

  withAlpha = color: opacity: "#${stripHash color}${toHex2 opacity}";
  rgba = color: opacity: "rgba(${stripHash color}${toHex2 opacity})";
  rgb = color: "rgb(${stripHash color})";
in
{
  inherit
    stripHash
    withAlpha
    rgba
    rgb
    ;

  colors = baseColors // {
    accent = currentAccent;
  };
  font = {
    base = f.monospace.name;
    mono = "${f.monospace.name} Mono";
    propo = "${f.monospace.name} Propo";
  };
  border = {
    radius = 8;
    width = 2;
  };
  spacing = {
    gapsIn = 3;
    gapsOut = 10;
  };
  opacity = {
    windowActive = 0.95;
    windowInactive = 0.85;
    popups = 0.85;
  };
  blur = {
    size = 6;
    passes = 3;
  };
}
