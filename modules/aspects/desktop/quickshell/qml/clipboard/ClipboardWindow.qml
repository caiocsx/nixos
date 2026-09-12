pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PanelWindow {
    id: root

    property string mode: "history"
    property string query: ""
    property bool confirmationVisible: false
    property string confirmationAction: ""
    property string statusMessage: ""
    readonly property var sourceItems: mode === "favorites" ? backend.favoriteItems : backend.historyItems
    readonly property var filteredItems: sourceItems.filter(item => item.text.toLowerCase().includes(query.toLowerCase()))

    onFilteredItemsChanged: listView.currentIndex = filteredItems.length > 0 ? 0 : -1

    function showMode(requestedMode) {
        mode = requestedMode === "favorites" ? "favorites" : "history"
        query = ""
        confirmationVisible = false
        visible = true
        backend.refresh(mode)
        Qt.callLater(() => searchField.forceActiveFocus())
    }

    function hideWindow() {
        visible = false
        confirmationVisible = false
        statusMessage = ""
    }

    function selectedItem() {
        if (listView.currentIndex < 0 || listView.currentIndex >= filteredItems.length)
            return null
        return filteredItems[listView.currentIndex]
    }

    function copySelected() {
        const item = selectedItem()
        if (item)
            backend.copy(item, mode)
    }

    function switchMode(nextMode) {
        mode = nextMode
        query = ""
        statusMessage = ""
        backend.refresh(mode)
        Qt.callLater(() => searchField.forceActiveFocus())
    }

    visible: false
    implicitWidth: 760
    implicitHeight: 540
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: true

    IpcHandler {
        target: "clipboard"

        function show(requestedMode: string): void {
            root.showMode(requestedMode)
        }

        function toggle(requestedMode: string): void {
            if (root.visible)
                root.hideWindow()
            else
                root.showMode(requestedMode)
        }
    }

    ClipboardBackend {
        id: backend

        onCommandFinished: (operation, success, message) => {
            if (!success) {
                root.statusMessage = message || "Clipboard operation failed"
                return
            }

            if (operation === "copy") {
                root.hideWindow()
                return
            }

            if (!operation.startsWith("load-"))
                backend.refresh(root.mode)
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: 11
        color: Theme.background
        border.width: 1
        border.color: Theme.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: 8
                color: Theme.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Text {
                        text: ""
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                    }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Search clipboard..."
                        text: root.query
                        color: Theme.foreground
                        placeholderTextColor: Theme.muted
                        selectionColor: Theme.active
                        selectedTextColor: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        background: null
                        onTextChanged: root.query = text

                        Keys.onPressed: event => {
                            if (root.confirmationVisible) {
                                if (event.key === Qt.Key_Escape) {
                                    root.confirmationVisible = false
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    root.confirmationVisible = false
                                    backend.clear(root.confirmationAction)
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_Down) {
                                listView.incrementCurrentIndex()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                listView.decrementCurrentIndex()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                root.copySelected()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Escape) {
                                root.hideWindow()
                                event.accepted = true
                            }
                        }
                    }

                    Text {
                        text: "Esc"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.mode === "favorites" ? "FAVORITES" : "CLIPBOARD HISTORY"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.filteredItems.length + (root.filteredItems.length === 1 ? " ITEM" : " ITEMS")
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                }

                ClipboardButton {
                    text: "History"
                    active: root.mode === "history"
                    onClicked: root.switchMode("history")
                }

                ClipboardButton {
                    text: "Favorites"
                    active: root.mode === "favorites"
                    onClicked: root.switchMode("favorites")
                }
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: root.filteredItems
                currentIndex: -1
                boundsBehavior: Flickable.StopAtBounds

                delegate: ClipboardItem {
                    required property var modelData
                    required property int index
                    width: listView.width
                    itemData: modelData
                    itemIndex: index
                    selected: ListView.isCurrentItem
                    onHovered: listView.currentIndex = index
                    onActivated: {
                        listView.currentIndex = index
                        root.copySelected()
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: listView.count === 0 && !backend.busy
                    text: root.query ? "No matching items" : root.mode === "favorites" ? "No favorites yet" : "Clipboard history is empty"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 8
                color: Theme.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    ClipboardButton {
                        text: "Copy"
                        enabled: root.selectedItem() !== null && !backend.busy
                        onClicked: root.copySelected()
                    }

                    ClipboardButton {
                        visible: root.mode === "history"
                        text: "Add favorite"
                        enabled: root.selectedItem() !== null && !backend.busy
                        onClicked: backend.addFavorite(root.selectedItem())
                    }

                    ClipboardButton {
                        text: root.mode === "favorites" ? "Remove favorite" : "Delete item"
                        enabled: root.selectedItem() !== null && !backend.busy
                        onClicked: backend.remove(root.selectedItem(), root.mode)
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        visible: root.statusMessage !== ""
                        text: root.statusMessage
                        textFormat: Text.PlainText
                        color: Theme.red
                        elide: Text.ElideRight
                        Layout.maximumWidth: 260
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }

                    ClipboardButton {
                        text: root.mode === "favorites" ? "Clear favorites" : "Clear history"
                        danger: true
                        enabled: root.sourceItems.length > 0 && !backend.busy
                        onClicked: {
                            root.confirmationAction = root.mode
                            root.confirmationVisible = true
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            visible: root.confirmationVisible
            color: Theme.overlay
            radius: 11

            MouseArea { anchors.fill: parent }

            Rectangle {
                anchors.centerIn: parent
                width: 380
                height: 150
                radius: 10
                color: Theme.surface
                border.width: 1
                border.color: Theme.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    Text {
                        Layout.fillWidth: true
                        text: root.confirmationAction === "favorites" ? "Clear all favorites?" : "Clear all clipboard history?"
                        color: Theme.foreground
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10

                        ClipboardButton {
                            text: "Cancel"
                            onClicked: root.confirmationVisible = false
                        }

                        ClipboardButton {
                            text: "Clear"
                            danger: true
                            onClicked: {
                                root.confirmationVisible = false
                                backend.clear(root.confirmationAction)
                            }
                        }
                    }
                }
            }
        }
    }
}
