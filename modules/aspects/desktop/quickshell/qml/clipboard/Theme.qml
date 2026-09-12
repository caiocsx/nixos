pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property color background: Quickshell.env("QS_BG") || "#1f303d"
    readonly property color surface: Quickshell.env("QS_SURFACE") || "#2a3b4b"
    readonly property color foreground: Quickshell.env("QS_FG") || "#dce8ef"
    readonly property color muted: Quickshell.env("QS_MUTED") || "#879baa"
    readonly property color accent: Quickshell.env("QS_ACCENT") || "#73b9d6"
    readonly property color red: Quickshell.env("QS_RED") || "#e8a2a2"
    readonly property color border: Quickshell.env("QS_BORDER") || "#73b9d673"
    readonly property color selected: Quickshell.env("QS_SELECTED") || "#73b9d63d"
    readonly property color active: Quickshell.env("QS_ACTIVE") || "#73b9d657"
    readonly property color hover: Quickshell.env("QS_HOVER") || "#73b9d62e"
    readonly property color button: Quickshell.env("QS_BUTTON") || "#dce8ef1a"
    readonly property color disabled: Quickshell.env("QS_DISABLED") || "#62748299"
    readonly property color overlay: Quickshell.env("QS_OVERLAY") || "#1f303db3"
    readonly property string fontFamily: Quickshell.env("QS_FONT") || "JetBrainsMono Nerd Font"
}
