pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "clipboard"

ShellRoot {
    id: root

    property int fontSize: 14

    PanelWindow {
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 30
        color: Theme.bg

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            Repeater {
                model: 9
                Text {
                    required property int index
                    property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                    property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                    text: index + 1
                    color: isActive || ws ? Theme.accent : Theme.muted
                    font { family: Theme.fontFamily; pixelSize: root.fontSize; bold: true }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = '${index + 1}'})`)
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                id: clock
                color: Theme.accent
                font { family: Theme.fontFamily; pixelSize: root.fontSize; bold: true }
                text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                }
            }
        }
    }

    ClipboardWindow {}
}
