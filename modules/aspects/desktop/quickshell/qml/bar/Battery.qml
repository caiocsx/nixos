import Quickshell.Services.UPower
import QtQuick
import qs

BarButton {
    id: root
    readonly property var battery: UPower.displayDevice
    readonly property int percentage: Math.round(battery?.percentage ?? 0)
    readonly property bool charging: !UPower.onBattery
    compact: true
    visible: battery?.isPresent ?? false
    icon: charging ? "󰂄" : percentage <= 10 ? "󰂃" : percentage < 30 ? "󰁻" : percentage < 50 ? "󰁽" : percentage < 70 ? "󰁿" : percentage < 90 ? "󰂁" : "󰁹"
    iconColor: percentage <= 10 ? Theme.red : percentage <= 20 ? Theme.yellow : charging ? Theme.green : Theme.fg
    tooltip: `${charging ? "Charging" : "Battery"}: ${percentage}%`
}
