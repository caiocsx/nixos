pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs

PanelWindow {
    id: root
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 41
    color: "transparent"

    Item {
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.leftMargin: 8
        anchors.rightMargin: 8

        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: 33
            spacing: 8
            Notification {}
            Clock {}
            Tray { panelWindow: root }
        }

        Workspaces {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: 33
        }

        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 33
            spacing: 8
            Audio {}
            Brightness {}

            Rectangle {
                Layout.preferredHeight: 33
                implicitWidth: systemRow.implicitWidth + 20
                radius: Theme.radius
                color: Theme.bg

                RowLayout {
                    id: systemRow
                    anchors.centerIn: parent
                    spacing: 14
                    Bluetooth {}
                    Network {}
                    Battery {}
                }
            }
        }
    }
}
