import Quickshell.Io
import QtQuick

BarButton {
    id: root
    property string state: "none"
    icon: state.includes("dnd") ? "󰪓" : state.includes("notification") ? "󱅫" : "󰂜"
    tooltip: "Notifications"
    onClicked: button => {
        command.command = button === Qt.RightButton ? ["swaync-client", "-d", "-sw"] : ["swaync-client", "-t", "-sw"]
        command.running = true
    }

    Process {
        command: ["swaync-client", "-swb"]
        running: true
        stdout: SplitParser { onRead: data => root.state = data.trim() }
    }
    Process { id: command }
}
