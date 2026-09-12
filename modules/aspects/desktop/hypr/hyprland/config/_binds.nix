{ lib }:
let
  lua = lib.generators.mkLuaInline;

  terminal = "$TERMINAL";
  fileManager = "$FILE_MANAGER";
  browser = "$BROWSER";
  editor = "$EDITOR";

  dsp = {
    exec = cmd: lua ''hl.dsp.exec_cmd("${cmd}")'';
    close = lua "hl.dsp.window.close()";
    float = lua ''hl.dsp.window.float({ action = "toggle" })'';
    floatSized =
      x: y:
      lua ''
        function()
          hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
          hl.dispatch(hl.dsp.window.resize({ x = ${toString x}, y = ${toString y}, exact = true }))
          hl.dispatch(hl.dsp.window.center())
        end
      '';
    fullscreen = lua "hl.dsp.window.fullscreen()";
    maximize = lua "hl.dsp.window.fullscreen({ maximize = true })";
    pseudo = lua "hl.dsp.window.pseudo()";
    layout = msg: lua ''hl.dsp.layout("${msg}")'';
    focus = dir: lua ''hl.dsp.focus({ direction = "${dir}" })'';
    swap = dir: lua ''hl.dsp.window.swap({ direction = "${dir}" })'';
    toggleSpecial = name: lua ''hl.dsp.workspace.toggle_special("${name}")'';
    moveToSpecial = name: lua ''hl.dsp.window.move({ workspace = "special:${name}" })'';
    moveToSpecialSilent =
      name: lua ''hl.dsp.window.move({ workspace = "special:${name}", silent = true })'';
    focusWorkspace = ws: lua ''hl.dsp.focus({ workspace = "${toString ws}" })'';
    moveToWorkspace = ws: lua ''hl.dsp.window.move({ workspace = "${toString ws}" })'';
    moveToWorkspaceSilent =
      ws: lua ''hl.dsp.window.move({ workspace = "${toString ws}", silent = true })'';
    drag = lua "hl.dsp.window.drag()";
    resize = lua "hl.dsp.window.resize()";
    resizeActive =
      x: y: lua "hl.dsp.window.resize({ x = ${toString x}, y = ${toString y}, relative = true })";
  };

  bind = keys: dispatcher: {
    _args = [
      keys
      dispatcher
    ];
  };
  bindOpts = keys: dispatcher: opts: {
    _args = [
      keys
      dispatcher
      opts
    ];
  };

  workspaceBinds = lib.concatMap (i: [
    (bind "SUPER + ${toString i}" (dsp.focusWorkspace i))
    (bind "SUPER + SHIFT + ${toString i}" (dsp.moveToWorkspace i))
    (bind "SUPER + ALT + ${toString i}" (dsp.moveToWorkspaceSilent i))
  ]) (lib.range 1 9);
in
[
  # --- Applications ---
  (bind "SUPER + Return" (dsp.exec terminal))
  (bind "SUPER + B" (dsp.exec browser))
  (bind "SUPER + E" (dsp.exec editor))
  (bind "SUPER + F" (dsp.exec fileManager))
  (bind "SUPER + R" (dsp.exec "launcher"))

  # --- System Controls & Menus ---
  (bind "SUPER + Delete" (dsp.exec "hyprshutdown"))
  (bind "SUPER + SHIFT + Delete" (
    dsp.exec "hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'"
  ))
  (bind "SUPER + ALT + Delete" (dsp.exec "hyprshutdown -t 'Restarting...' --post-cmd 'reboot'"))
  (bind "SUPER + ESCAPE" (dsp.exec "power-menu"))
  (bind "SUPER + ALT + L" (dsp.exec "hyprlock"))
  (bind "SUPER + A" (dsp.exec "swaync-client -t -sw"))
  (bind "SUPER + SHIFT + N" (dsp.exec "network-manager"))
  (bind "SUPER + SHIFT + B" (dsp.exec "blueman-manager"))
  (bind "SUPER + EQUAL" (dsp.exec "calculator"))
  (bind "SUPER + period" (dsp.exec "character-picker"))

  # --- Wallpaper Management ---
  (bind "SUPER + SHIFT + W" (dsp.exec "wallpaper-picker"))
  (bind "SUPER + SHIFT + A" (dsp.exec "wallpaper-picker --prev"))
  (bind "SUPER + SHIFT + D" (dsp.exec "wallpaper-picker --next"))

  # --- Clipboard Management ---
  (bind "SUPER + V" (dsp.exec "clipboard-manager --history"))
  (bind "SUPER + SHIFT + V" (dsp.exec "clipboard-manager --favorites"))

  # --- Screenshots ---
  (bind "SUPER + PRINT" (dsp.exec "screenshot --window"))
  (bind "SUPER + SHIFT + PRINT" (dsp.exec "screenshot --region"))
  (bind "SUPER + CTRL + PRINT" (dsp.exec "screenshot --output"))

  # --- Accessibility / Screen Zoom ---
  (bind "SUPER + ALT + mouse_up" (lua "function() hl.config({ cursor = { zoom_factor = 1.5 } }) end"))
  (bind "SUPER + ALT + mouse_down" (
    lua "function() hl.config({ cursor = { zoom_factor = 1.0 } }) end"
  ))

  # --- Window State & Layout ---
  (bind "SUPER + C" dsp.close)
  (bind "SUPER + SHIFT + C" (dsp.exec "hyprctl kill"))
  (bind "SUPER + W" (dsp.floatSized 1000 660))
  (bind "SUPER + ALT + W" dsp.float)
  (bind "SUPER + P" dsp.pseudo)
  (bind "SUPER + SPACE" dsp.maximize)
  (bind "SUPER + ALT + J" (dsp.layout "togglesplit"))
  (bind "SUPER + bracketleft" (dsp.layout "splitratio -0.05"))
  (bind "SUPER + bracketright" (dsp.layout "splitratio +0.05"))

  # --- Window Navigation & Movement ---
  (bind "SUPER + H" (dsp.focus "left"))
  (bind "SUPER + L" (dsp.focus "right"))
  (bind "SUPER + K" (dsp.focus "up"))
  (bind "SUPER + J" (dsp.focus "down"))
  (bind "SUPER + SHIFT + H" (dsp.swap "left"))
  (bind "SUPER + SHIFT + L" (dsp.swap "right"))
  (bind "SUPER + SHIFT + K" (dsp.swap "up"))
  (bind "SUPER + SHIFT + J" (dsp.swap "down"))

  # --- Window Resizing ---
  (bindOpts "SUPER + SHIFT + Right" (dsp.resizeActive 30 0) { repeating = true; })
  (bindOpts "SUPER + SHIFT + Left" (dsp.resizeActive (-30) 0) { repeating = true; })
  (bindOpts "SUPER + SHIFT + Up" (dsp.resizeActive 0 (-30)) { repeating = true; })
  (bindOpts "SUPER + SHIFT + Down" (dsp.resizeActive 0 30) { repeating = true; })

  # --- Workspace Navigation & Scratchpad ---
  (bind "SUPER + CTRL + Right" (dsp.focusWorkspace "r+1"))
  (bind "SUPER + CTRL + Left" (dsp.focusWorkspace "r-1"))
  (bind "SUPER + mouse_down" (dsp.focusWorkspace "e+1"))
  (bind "SUPER + mouse_up" (dsp.focusWorkspace "e-1"))
  (bind "SUPER + S" (dsp.toggleSpecial "special"))
  (bind "SUPER + SHIFT + S" (dsp.moveToSpecial "special"))
  (bind "SUPER + ALT + S" (dsp.moveToSpecialSilent "special"))

  # --- Audio & Hardware Controls ---
  (bindOpts "XF86AudioRaiseVolume" (dsp.exec "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+") {
    locked = true;
    repeating = true;
  })
  (bindOpts "XF86AudioLowerVolume" (dsp.exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") {
    locked = true;
    repeating = true;
  })
  (bindOpts "XF86AudioMute" (dsp.exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") {
    locked = true;
  })

  # --- Media Controls ---
  (bindOpts "XF86AudioPlay" (dsp.exec "playerctl play-pause") { locked = true; })
  (bindOpts "XF86AudioNext" (dsp.exec "playerctl next") { locked = true; })
  (bindOpts "XF86AudioPrev" (dsp.exec "playerctl previous") { locked = true; })
  (bindOpts "XF86AudioStop" (dsp.exec "playerctl stop") { locked = true; })

  # --- Display Brightness ---
  (bindOpts "XF86MonBrightnessUp" (dsp.exec "brightnessctl set +10%") {
    locked = true;
    repeating = true;
  })
  (bindOpts "XF86MonBrightnessDown" (dsp.exec "brightnessctl set 10%-") {
    locked = true;
    repeating = true;
  })

  # --- Mouse Window Controls ---
  (bindOpts "SUPER + mouse:272" dsp.drag { mouse = true; })
  (bindOpts "SUPER + mouse:273" dsp.resize { mouse = true; })
]
++ workspaceBinds
