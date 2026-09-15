import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

Rectangle {
    id: root
    property int percentage: 0
    property bool expanded: hoverHandler.hovered || slider.hovered
    property bool adjusting: false
    property string executable: ""
    visible: executable.length > 0
    Layout.preferredHeight: 33
    implicitWidth: brightnessRow.implicitWidth + 20
    radius: Theme.radius
    color: Theme.bg

    function refresh() {
        if (executable.length > 0 && !reader.running)
            reader.running = true
    }

    RowLayout {
        id: brightnessRow
        anchors.centerIn: parent
        spacing: 8
        Text {
            text: root.percentage < 34 ? "󰃞" : root.percentage < 67 ? "󰃟" : "󰃠"
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 17
        }
        Slider {
            id: slider
            visible: root.expanded
            Layout.preferredWidth: visible ? 100 : 0
            from: 5
            to: 100
            value: root.percentage
            onPressedChanged: {
                if (pressed) {
                    root.adjusting = true
                } else if (root.adjusting) {
                    setter.command = [root.executable, "set", `${Math.round(value)}%`]
                    setter.running = true
                    root.percentage = Math.round(value)
                    root.adjusting = false
                }
            }
        }
    }

    HoverHandler { id: hoverHandler }
    Process {
        id: resolver
        command: ["sh", "-c", "command -v brightnessctl"]
        running: true
        stdout: StdioCollector { id: executableOutput }
        onExited: {
            root.executable = executableOutput.text.trim()
            root.refresh()
        }
    }
    Process {
        id: reader
        command: [root.executable, "-m"]
        stdout: StdioCollector { id: output }
        onExited: {
            const fields = output.text.trim().split(",")
            if (fields.length >= 4)
                root.percentage = parseInt(fields[3])
        }
    }
    Process { id: setter; onExited: root.refresh() }
    Timer { interval: 5000; running: root.executable.length > 0; repeat: true; onTriggered: root.refresh() }
}
