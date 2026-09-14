{
  pkgs,
  ui,
}:
let
  qmlString = builtins.toJSON;
in
pkgs.writeText "Theme.qml" ''
  pragma Singleton

  import Quickshell
  import QtQuick

  Singleton {
      readonly property color bg: ${qmlString ui.colors.bg}
      readonly property color surface: ${qmlString ui.colors.surface}
      readonly property color fg: ${qmlString ui.colors.fg}
      readonly property color muted: ${qmlString ui.colors.muted}
      readonly property color accent: ${qmlString ui.colors.accent}
      readonly property color cyan: ${qmlString ui.colors.cyan}
      readonly property color blue: ${qmlString ui.colors.blue}
      readonly property color green: ${qmlString ui.colors.green}
      readonly property color magenta: ${qmlString ui.colors.magenta}
      readonly property color orange: ${qmlString ui.colors.orange}
      readonly property color purple: ${qmlString ui.colors.purple}
      readonly property color red: ${qmlString ui.colors.red}
      readonly property color yellow: ${qmlString ui.colors.yellow}
      readonly property string fontFamily: ${qmlString ui.font.base}
      readonly property string monoFontFamily: ${qmlString ui.font.mono}
      readonly property string proportionalFontFamily: ${qmlString ui.font.propo}
      readonly property int radius: ${toString ui.border.radius}
      readonly property int borderWidth: ${toString ui.border.width}
      readonly property int gap: ${toString ui.spacing.gapsIn}
      readonly property int outerGap: ${toString ui.spacing.gapsOut}
      readonly property real popupOpacity: ${toString ui.opacity.popups}

      function withAlpha(color, opacity) {
          return Qt.rgba(color.r, color.g, color.b, opacity)
      }
  }
''
