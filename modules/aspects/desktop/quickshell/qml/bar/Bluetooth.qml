import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick

BarButton {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property int connectedDevices: Bluetooth.devices.values.filter(device => device.connected).length
    compact: true
    icon: !adapter || !adapter.enabled ? "󰂲" : connectedDevices > 0 ? "󰂱" : "󰂯"
    tooltip: !adapter ? "No Bluetooth controller" : !adapter.enabled ? "Bluetooth disabled" : connectedDevices > 0 ? `${connectedDevices} Bluetooth device(s) connected` : "Bluetooth enabled"
    onClicked: button => button === Qt.RightButton ? rfkill.running = true : manager.running = true

    Process { id: manager; command: ["blueman-manager"] }
    Process { id: rfkill; command: ["rfkill", "toggle", "bluetooth"] }
}
