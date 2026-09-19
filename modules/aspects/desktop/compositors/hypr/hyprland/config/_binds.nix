{ lib }:
let
  lua = lib.generators.mkLuaInline;

  terminal = "$TERMINAL";
  fileManager = "$FILE_MANAGER";
  browser = "$BROWSER";
  editor = "$EDITOR";

  dsp = {
    exec = cmd: lua ''hl.dsp.exec_cmd("${cmd}")'';
    app = cmd: lua ''hl.dsp.exec_cmd("uwsm app -- ${cmd}")'';
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

  bind = keys: description: dispatcher: {
    _args = [
      keys
      dispatcher
      { inherit description; }
    ];
  };
  bindOpts = keys: description: dispatcher: opts: {
    _args = [
      keys
      dispatcher
      (opts // { inherit description; })
    ];
  };

  workspaceBinds = lib.concatMap (i: [
    (bind "SUPER + ${toString i}" "Focus workspace ${toString i}" (dsp.focusWorkspace i))
    (bind "SUPER + SHIFT + ${toString i}" "Move window to workspace ${toString i}" (
      dsp.moveToWorkspace i
    ))
    (bind "SUPER + ALT + ${toString i}" "Move window silently to workspace ${toString i}" (
      dsp.moveToWorkspaceSilent i
    ))
  ]) (lib.range 1 9);
in
[
  # --- Applications ---
  (bind "SUPER + Return" "Open terminal" (dsp.app terminal))
  (bind "SUPER + B" "Open browser" (dsp.app browser))
  (bind "SUPER + E" "Open editor" (dsp.app editor))
  (bind "SUPER + F" "Open file manager" (dsp.app fileManager))
  (bind "SUPER + R" "Open application launcher" (dsp.exec "launcher"))

  # --- System Controls & Menus ---
  (bind "SUPER + Delete" "Open power menu" (dsp.exec "power-menu"))
  (bind "SUPER + SHIFT + Delete" "Shut down session" (dsp.exec "session-shutdown"))
  (bind "SUPER + ALT + Delete" "Reboot session" (dsp.exec "session-reboot"))
  (bind "SUPER + ESCAPE" "Open power menu" (dsp.exec "power-menu"))
  (bind "SUPER + ALT + L" "Lock session" (dsp.exec "session-lock"))
  (bind "SUPER + A" "Toggle control center" (dsp.exec "control-center-toggle"))
  (bind "SUPER + SHIFT + B" "Toggle status bar" (dsp.exec "bar-toggle"))
  (bind "SUPER + period" "Open character picker" (dsp.exec "character-picker"))

  # --- Wallpaper Management ---
  (bind "SUPER + W" "Open wallpaper picker" (dsp.exec "wallpaper-picker"))
  (bind "SUPER + ALT + bracketleft" "Select previous wallpaper" (dsp.exec "wallpaper-picker --prev"))
  (bind "SUPER + ALT + bracketright" "Select next wallpaper" (dsp.exec "wallpaper-picker --next"))

  # --- Clipboard Management ---
  (bind "SUPER + V" "Open clipboard history" (dsp.exec "clipboard"))
  (bind "SUPER + SHIFT + V" "Clear clipboard history" (dsp.exec "clipboard --wipe"))

  # --- Screenshots ---
  (bind "SUPER + PRINT" "Capture active window" (dsp.exec "screenshot --window"))
  (bind "SUPER + SHIFT + PRINT" "Capture selected region" (dsp.exec "screenshot --region"))
  (bind "SUPER + CTRL + PRINT" "Capture current output" (dsp.exec "screenshot --output"))

  # --- Accessibility / Screen Zoom ---
  (bind "SUPER + ALT + mouse_up" "Zoom in" (
    lua "function() hl.config({ cursor = { zoom_factor = 1.5 } }) end"
  ))
  (bind "SUPER + ALT + mouse_down" "Reset zoom" (
    lua "function() hl.config({ cursor = { zoom_factor = 1.0 } }) end"
  ))

  # --- Window State & Layout ---
  (bind "SUPER + SPACE" "Toggle window maximization" dsp.maximize)
  (bind "SUPER + Q" "Close active window" dsp.close)
  (bind "SUPER + SHIFT + Q" "Kill a window" (dsp.exec "hyprctl kill"))
  (bind "SUPER + SHIFT + W" "Toggle sized floating window" (dsp.floatSized 1000 660))
  (bind "SUPER + ALT + W" "Toggle floating window" dsp.float)
  (bind "SUPER + P" "Toggle pseudo-tiling" dsp.pseudo)
  (bind "SUPER + T" "Toggle split orientation" (dsp.layout "togglesplit"))
  (bind "SUPER + bracketleft" "Decrease split ratio" (dsp.layout "splitratio -0.05"))
  (bind "SUPER + bracketright" "Increase split ratio" (dsp.layout "splitratio +0.05"))

  # --- Window Navigation & Movement ---
  (bind "SUPER + H" "Focus window to the left" (dsp.focus "left"))
  (bind "SUPER + L" "Focus window to the right" (dsp.focus "right"))
  (bind "SUPER + K" "Focus window above" (dsp.focus "up"))
  (bind "SUPER + J" "Focus window below" (dsp.focus "down"))
  (bind "SUPER + SHIFT + H" "Move window left" (dsp.swap "left"))
  (bind "SUPER + SHIFT + L" "Move window right" (dsp.swap "right"))
  (bind "SUPER + SHIFT + K" "Move window up" (dsp.swap "up"))
  (bind "SUPER + SHIFT + J" "Move window down" (dsp.swap "down"))

  # --- Window Resizing ---
  (bindOpts "SUPER + SHIFT + Right" "Grow window to the right" (dsp.resizeActive 30 0) {
    repeating = true;
  })
  (bindOpts "SUPER + SHIFT + Left" "Grow window to the left" (dsp.resizeActive (-30) 0) {
    repeating = true;
  })
  (bindOpts "SUPER + SHIFT + Up" "Shrink window vertically" (dsp.resizeActive 0 (-30)) {
    repeating = true;
  })
  (bindOpts "SUPER + SHIFT + Down" "Grow window vertically" (dsp.resizeActive 0 30) {
    repeating = true;
  })

  # --- Mouse Window Controls ---
  (bindOpts "SUPER + mouse:272" "Move window with mouse" dsp.drag { mouse = true; })
  (bindOpts "SUPER + mouse:273" "Resize window with mouse" dsp.resize { mouse = true; })

  # --- Workspace Navigation & Scratchpad ---
  (bind "SUPER + CTRL + Right" "Focus next workspace" (dsp.focusWorkspace "r+1"))
  (bind "SUPER + CTRL + Left" "Focus previous workspace" (dsp.focusWorkspace "r-1"))
  (bind "SUPER + mouse_down" "Focus next existing workspace" (dsp.focusWorkspace "e+1"))
  (bind "SUPER + mouse_up" "Focus previous existing workspace" (dsp.focusWorkspace "e-1"))
  (bind "SUPER + S" "Toggle special workspace" (dsp.toggleSpecial "special"))
  (bind "SUPER + SHIFT + S" "Move window to special workspace" (dsp.moveToSpecial "special"))
  (bind "SUPER + ALT + S" "Move window silently to special workspace" (
    dsp.moveToSpecialSilent "special"
  ))

  # --- Audio & Hardware Controls ---
  (bindOpts "XF86AudioRaiseVolume" "Raise volume"
    (dsp.exec "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+")
    {
      locked = true;
      repeating = true;
    }
  )
  (bindOpts "XF86AudioLowerVolume" "Lower volume"
    (dsp.exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
    {
      locked = true;
      repeating = true;
    }
  )
  (bindOpts "XF86AudioMute" "Toggle audio mute"
    (dsp.exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
    { locked = true; }
  )

  # --- Media Controls ---
  (bindOpts "XF86AudioPlay" "Play or pause media" (dsp.exec "playerctl play-pause") {
    locked = true;
  })
  (bindOpts "XF86AudioNext" "Play next track" (dsp.exec "playerctl next") { locked = true; })
  (bindOpts "XF86AudioPrev" "Play previous track" (dsp.exec "playerctl previous") { locked = true; })
  (bindOpts "XF86AudioStop" "Stop media playback" (dsp.exec "playerctl stop") { locked = true; })

  # --- Display Brightness ---
  (bindOpts "XF86MonBrightnessUp" "Raise display brightness" (dsp.exec "brightnessctl set +10%") {
    locked = true;
    repeating = true;
  })
  (bindOpts "XF86MonBrightnessDown" "Lower display brightness" (dsp.exec "brightnessctl set 10%-") {
    locked = true;
    repeating = true;
  })
]
++ workspaceBinds
