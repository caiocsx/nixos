{ ui }:
''
  @define-color bg        alpha(${ui.colors.bg}, ${toString ui.opacity.popups});
  @define-color surface   alpha(${ui.colors.surface}, ${toString ui.opacity.popups});
  @define-color fg        ${ui.colors.fg};
  @define-color muted     ${ui.colors.muted};
  @define-color cyan      ${ui.colors.cyan};
  @define-color blue      ${ui.colors.blue};
  @define-color green     ${ui.colors.green};
  @define-color magenta   ${ui.colors.magenta};
  @define-color orange    ${ui.colors.orange};
  @define-color purple    ${ui.colors.purple};
  @define-color red       ${ui.colors.red};
  @define-color yellow    ${ui.colors.yellow};
''
