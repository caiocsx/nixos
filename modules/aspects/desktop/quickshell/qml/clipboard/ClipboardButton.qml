import QtQuick
import QtQuick.Controls

Button {
    id: root

    property bool active: false
    property bool danger: false

    implicitHeight: 32
    leftPadding: 12
    rightPadding: 12

    contentItem: Text {
        text: root.text
        color: root.enabled ? root.danger ? Theme.red : Theme.fg : Theme.muted
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: Theme.fontFamily
        font.pixelSize: 10
        font.bold: root.active
    }

    background: Rectangle {
        radius: Theme.radius
        color: root.active ? Theme.withAlpha(Theme.accent, 0.34) : root.hovered ? Theme.withAlpha(Theme.accent, 0.18) : Theme.withAlpha(Theme.fg, 0.1)
        border.width: root.active ? 1 : 0
        border.color: Theme.accent
    }
}
