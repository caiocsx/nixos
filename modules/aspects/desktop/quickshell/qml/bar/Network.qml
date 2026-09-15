import Quickshell.Io
import QtQuick

BarButton {
    id: root
    property string connectionType: "disconnected"
    property string connectionName: "Disconnected"
    property int signalStrength: 0
    compact: true
    icon: connectionType === "ethernet" ? "󰈀" : connectionType === "wifi" ? signalStrength < 25 ? "󰤯" : signalStrength < 50 ? "󰤟" : signalStrength < 75 ? "󰤥" : "󰤨" : "󰲛"
    tooltip: connectionName
    onClicked: button => button === Qt.RightButton ? terminal.running = true : manager.running = true

    Process {
        id: reader
        command: ["sh", "-c", "nmcli -t -f TYPE,NAME connection show --active | head -n1; nmcli -t -f IN-USE,SIGNAL device wifi | sed -n 's/^\\*://p' | head -n1"]
        stdout: StdioCollector { id: output }
        onExited: {
            const lines = output.text.trim().split("\n")
            const connection = (lines[0] || "").split(":")
            root.connectionType = connection[0] === "802-11-wireless" ? "wifi" : connection[0] === "802-3-ethernet" ? "ethernet" : "disconnected"
            root.connectionName = connection.length > 1 ? connection.slice(1).join(":") : "Disconnected"
            root.signalStrength = parseInt(lines[1] || "0")
        }
    }
    Process { id: manager; command: ["nm-connection-editor"] }
    Process { id: terminal; command: ["kitty", "-e", "nmtui"] }
    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: if (!reader.running) reader.running = true }
}
