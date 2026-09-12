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
        color: root.enabled ? root.danger ? Theme.red : Theme.foreground : Theme.disabled
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: Theme.fontFamily
        font.pixelSize: 10
        font.bold: root.active
    }

    background: Rectangle {
        radius: 6
        color: root.active ? Theme.active : root.hovered ? Theme.hover : Theme.button
        border.width: root.active ? 1 : 0
        border.color: Theme.accent
    }
}
