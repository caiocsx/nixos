pragma ComponentBehavior: Bound

import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    required property var panelWindow
    spacing: 8

    Repeater {
        model: SystemTray.items
        Item {
            id: delegate
            required property var modelData
            Layout.preferredWidth: 25
            Layout.preferredHeight: 33

            IconImage {
                anchors.centerIn: parent
                implicitWidth: 16
                implicitHeight: 16
                source: delegate.modelData.icon
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                onClicked: event => {
                    if (event.button === Qt.RightButton || delegate.modelData.onlyMenu)
                        delegate.modelData.display(root.panelWindow, delegate.x, delegate.height)
                    else if (event.button === Qt.MiddleButton)
                        delegate.modelData.secondaryActivate()
                    else
                        delegate.modelData.activate()
                }
                onWheel: event => delegate.modelData.scroll(event.angleDelta.y, false)
            }
        }
    }
}
