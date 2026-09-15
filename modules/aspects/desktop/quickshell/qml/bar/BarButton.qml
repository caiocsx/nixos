import QtQuick
import QtQuick.Controls
import qs

Rectangle {
    id: root
    required property string icon
    property string tooltip: ""
    property color iconColor: Theme.fg
    property bool compact: false
    signal clicked(int button)
    signal wheel(int delta)

    implicitWidth: compact ? 25 : Math.max(33, label.implicitWidth + 20)
    implicitHeight: 33
    radius: Theme.radius
    color: compact ? "transparent" : Theme.bg

    Text {
        id: label
        anchors.centerIn: parent
        text: root.icon
        color: mouseArea.containsMouse ? Theme.blue : root.iconColor
        font.family: Theme.fontFamily
        font.pixelSize: 17
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        hoverEnabled: true
        onClicked: event => root.clicked(event.button)
        onWheel: event => root.wheel(event.angleDelta.y)
    }

    ToolTip.visible: mouseArea.containsMouse && tooltip.length > 0
    ToolTip.text: tooltip
    ToolTip.delay: 500
}
