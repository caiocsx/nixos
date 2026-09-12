import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    required property var itemData
    required property bool selected
    required property int itemIndex

    signal activated
    signal hovered

    readonly property bool imageItem: itemData.text.startsWith("[[ binary data")
    readonly property bool linkItem: /^https?:\/\//i.test(itemData.text)

    implicitHeight: 66
    radius: 8
    color: selected ? Theme.selected : mouseArea.containsMouse ? Theme.hover : "transparent"
    border.width: selected ? 1 : 0
    border.color: Theme.accent

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 7
            color: Theme.button

            Text {
                anchors.centerIn: parent
                text: root.imageItem ? "" : root.linkItem ? "" : ""
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 17
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: root.itemData.text || "Empty clipboard item"
                textFormat: Text.PlainText
                color: Theme.foreground
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
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered()
        onClicked: root.activated()
    }
}
