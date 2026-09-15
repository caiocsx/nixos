import QtQuick

BarButton {
    id: root
    property date now: new Date()
    property bool alternate: false
    icon: alternate ? Qt.formatDateTime(now, "HH:mm - MMMM dd, yyyy") : Qt.formatDateTime(now, "HH:mm:ss")
    tooltip: Qt.formatDateTime(now, "dddd, MMMM dd, yyyy")
    onClicked: button => { if (button === Qt.RightButton) alternate = !alternate }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
