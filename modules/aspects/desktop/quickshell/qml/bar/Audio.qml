import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

RowLayout {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    property bool expanded: hoverHandler.hovered || sinkSlider.hovered
    spacing: 8

    PwObjectTracker { objects: [root.sink, root.source] }

    BarButton {
        icon: root.source?.audio?.muted ? "󰍭" : "󰍬"
        tooltip: root.source?.audio?.muted ? "Microphone muted" : "Microphone active"
        onClicked: if (root.source?.audio) root.source.audio.muted = !root.source.audio.muted
    }

    Rectangle {
        Layout.preferredHeight: 33
        implicitWidth: audioRow.implicitWidth + 20
        radius: Theme.radius
        color: Theme.bg

        RowLayout {
            id: audioRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: root.sink?.audio?.muted ? "" : root.sink?.audio?.volume < 0.34 ? "" : root.sink?.audio?.volume < 0.67 ? "" : ""
                color: sinkMouse.containsMouse ? Theme.blue : Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 17

                MouseArea {
                    id: sinkMouse
                    anchors.fill: parent
                    anchors.margins: -8
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    onClicked: event => {
                        if (!root.sink?.audio)
                            return
                        if (event.button === Qt.RightButton)
                            root.sink.audio.muted = !root.sink.audio.muted
                        else
                            pavucontrol.running = true
                    }
                    onWheel: event => {
                        if (root.sink?.audio)
                            root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05)))
                    }
                }
            }

            Slider {
                id: sinkSlider
                visible: root.expanded
                Layout.preferredWidth: visible ? 100 : 0
                from: 0
                to: 1
                value: root.sink?.audio?.volume ?? 0
                onPressedChanged: {
                    if (!pressed && root.sink?.audio)
                        root.sink.audio.volume = value
                }
            }
        }
        HoverHandler { id: hoverHandler }
    }

    Process { id: pavucontrol; command: ["pavucontrol"] }
}
