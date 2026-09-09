{ ui, ... }:
''
  * {
    bg:               ${ui.withAlpha ui.colors.bg ui.opacity.popups};
    bg-solid:         ${ui.colors.bg};
    surface:          ${ui.withAlpha ui.colors.surface ui.opacity.popups};
    surface-solid:    ${ui.colors.surface};
    fg:               ${ui.colors.fg};
    muted:            ${ui.colors.muted};

    accent:           ${ui.colors.accent};

    cyan:             ${ui.colors.cyan};
    blue:             ${ui.colors.blue};
    green:            ${ui.colors.green};
    magenta:          ${ui.colors.magenta};
    orange:           ${ui.colors.orange};
    purple:           ${ui.colors.purple};
    red:              ${ui.colors.red};
    yellow:           ${ui.colors.yellow};

    radius:           ${toString ui.border.radius}px;
  }

  scrollbar {
    handle-rounded-corners: true;
    handle-color:           @accent;
    background-color:       @surface;
  }

  element selected.normal {
    text-color:          @surface-solid;
    background-color:    @accent;
  }

  button selected {
    text-color:          @surface-solid;
    background-color:    @accent;
  }
''
