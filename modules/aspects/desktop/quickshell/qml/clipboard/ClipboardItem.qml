import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    required property var itemData
    required property bool selected
    required property int itemIndex
    property int currentTime: 0
    property bool actionsEnabled: true

    signal activated
    signal selectionRequested
    signal favoriteToggled
    signal removeRequested

    readonly property bool hovered: hoverHandler.hovered
    readonly property bool imageItem: itemData.text.startsWith("[[ binary data")
    readonly property bool linkItem: /^https?:\/\//i.test(itemData.text)

    function relativeTime(timestamp) {
        if (!timestamp)
            return ""

        const elapsed = Math.max(0, currentTime - timestamp)
        if (elapsed < 60)
            return "Now"
        if (elapsed < 3600)
            return Math.floor(elapsed / 60) + " min"
        if (elapsed < 86400)
            return Math.floor(elapsed / 3600) + " hr"
        return Math.floor(elapsed / 86400) + " d"
    }

    implicitHeight: 66
    radius: Theme.radius
    color: selected ? Theme.withAlpha(Theme.accent, 0.24) : hovered ? Theme.withAlpha(Theme.accent, 0.18) : Theme.withAlpha(Theme.bg, 0)
    border.width: selected ? Theme.borderWidth : 0
    border.color: Theme.accent

    HoverHandler { id: hoverHandler }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.outerGap
        anchors.rightMargin: Theme.outerGap
        spacing: Theme.outerGap

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                spacing: Theme.outerGap

                Rectangle {
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38
                    radius: Theme.radius
                    color: Theme.accent

                    Text {
                        anchors.centerIn: parent
                        text: root.imageItem ? "" : root.linkItem ? "" : ""
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 17
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.gap

                    Text {
                        Layout.fillWidth: true
                        text: root.itemData.text || "Empty clipboard item"
                        textFormat: Text.PlainText
                        color: Theme.fg
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        text: root.imageItem ? "Image" : root.linkItem ? "Link" : "Text snippet"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.selectionRequested()
                    root.activated()
                }
            }
        }

        Text {
            Layout.preferredWidth: 48
            text: root.relativeTime(root.itemData.timestamp)
            color: Theme.muted
            horizontalAlignment: Text.AlignRight
            font.family: Theme.fontFamily
            font.pixelSize: 10
        }

        Item {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30

            Text {
                anchors.centerIn: parent
                text: root.itemData.favorite ? "" : ""
                color: root.itemData.favorite ? Theme.yellow : Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 15
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.actionsEnabled
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.selectionRequested()
                    root.favoriteToggled()
                }
            }
        }

        Item {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            opacity: root.selected || root.hovered ? 1 : 0

            Text {
                anchors.centerIn: parent
                text: ""
                color: Theme.red
                font.family: Theme.fontFamily
                font.pixelSize: 14
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.actionsEnabled && (root.selected || root.hovered)
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.selectionRequested()
                    root.removeRequested()
                }
            }
        }
    }
}
