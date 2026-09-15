pragma ComponentBehavior: Bound

import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs

Rectangle {
    id: root
    implicitWidth: workspaceRow.implicitWidth + 20
    radius: Theme.radius
    color: Theme.bg

    RowLayout {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: 5
            Text {
                required property int index
                readonly property int workspaceId: index + 1
                readonly property bool occupied: Hyprland.workspaces.values.some(workspace => workspace.id === workspaceId)
                readonly property bool active: Hyprland.focusedWorkspace?.id === workspaceId
                text: ""
                color: active ? Theme.muted : occupied ? Theme.withAlpha(Theme.muted, 0.4) : Theme.withAlpha(Theme.muted, 0.15)
                font.family: Theme.fontFamily
                font.pixelSize: 12

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -5
                    onClicked: Hyprland.dispatch(`workspace ${parent.workspaceId}`)
                }
            }
        }
    }
}
