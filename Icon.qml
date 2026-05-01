import Quickshell.Widgets
import QtQuick

WrapperItem {
    id: icon_root

    required property string text
    required property string color
    required property int radius
    property bool inverted: false
    property string textColor: root.fg
    property string font: root.iconFont

    override default property alias data: container.data

    Rectangle {
        id: container

        color: icon_root.inverted ? icon_root.textColor : icon_root.color
        implicitHeight: 2 * icon_root.radius
        implicitWidth: 2 * icon_root.radius
        radius: icon_root.radius

        Text {
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            text: icon_root.text
            font.family: icon_root.font
            font.pixelSize: 16
            color: !icon_root.inverted ? icon_root.textColor : icon_root.color
        }
    }
}
