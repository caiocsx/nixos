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
    property string selectedKey: ""
    property int currentTime: Math.floor(Date.now() / 1000)
    readonly property var sourceItems: mode === "favorites" ? backend.favoriteItems : backend.historyItems
    readonly property var filteredItems: sourceItems.filter(item => item.text.toLowerCase().includes(query.toLowerCase()))

    onFilteredItemsChanged: {
        const previousIndex = filteredItems.findIndex(item => itemKey(item) === selectedKey)
        selectItem(previousIndex >= 0 ? previousIndex : filteredItems.length > 0 ? 0 : -1)
    }

    function itemKey(item) {
        return mode === "favorites" ? item.token : item.id
    }

    function selectItem(index) {
        listView.currentIndex = index
        selectedKey = index >= 0 && index < filteredItems.length ? itemKey(filteredItems[index]) : ""
    }

    function showMode(requestedMode) {
        mode = requestedMode === "favorites" ? "favorites" : "history"
        query = ""
        selectedKey = ""
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
        selectedKey = ""
        statusMessage = ""
        backend.refresh(mode)
        Qt.callLater(() => searchField.forceActiveFocus())
    }

    visible: false
    implicitWidth: 760
    implicitHeight: 540
    color: Theme.withAlpha(Theme.bg, 0)
    exclusionMode: ExclusionMode.Ignore
    focusable: true

    Timer {
        interval: 30000
        running: root.visible
        repeat: true
        onTriggered: root.currentTime = Math.floor(Date.now() / 1000)
    }

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
        anchors.margins: Theme.gap
        radius: Theme.radius
        color: Theme.bg
        border.width: Theme.borderWidth
        border.color: Theme.accent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.outerGap
            spacing: Theme.outerGap

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: Theme.radius
                color: Theme.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: Theme.outerGap

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
                        color: Theme.fg
                        placeholderTextColor: Theme.muted
                        selectionColor: Theme.withAlpha(Theme.accent, 0.34)
                        selectedTextColor: Theme.fg
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
                                root.selectItem(listView.currentIndex)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                listView.decrementCurrentIndex()
                                root.selectItem(listView.currentIndex)
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
                spacing: Theme.gap

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
                    currentTime: root.currentTime
                    actionsEnabled: !backend.busy
                    onSelectionRequested: root.selectItem(index)
                    onActivated: {
                        root.selectItem(index)
                        backend.copy(modelData, root.mode)
                    }
                    onFavoriteToggled: backend.toggleFavorite(modelData, root.mode)
                    onRemoveRequested: backend.remove(modelData, root.mode)
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
                radius: Theme.radius
                color: Theme.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: Theme.gap

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
            color: Theme.withAlpha(Theme.bg, Theme.popupOpacity)
            radius: Theme.radius

            MouseArea { anchors.fill: parent }

            Rectangle {
                anchors.centerIn: parent
                width: 380
                height: 150
                radius: Theme.radius
                color: Theme.surface
                border.width: Theme.borderWidth
                border.color: Theme.accent

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: Theme.outerGap

                    Text {
                        Layout.fillWidth: true
                        text: root.confirmationAction === "favorites" ? "Clear all favorites?" : "Clear all clipboard history?"
                        color: Theme.fg
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Theme.outerGap

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
