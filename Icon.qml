import Quickshell.Widgets
import QtQuick

WrapperItem {
    id: icon_root

    required property string text
    required property int extraMargin
    required property string color
    required property int radius
    property bool inverted: false
    property string textColor: "white"
    property string font: root.iconFont

    WrapperRectangle {
        color: icon_root.inverted ? icon_root.textColor : icon_root.color
        implicitHeight: 2 * icon_root.radius
        implicitWidth: 2 * icon_root.radius
        radius: icon_root.radius
        //extraMargin: icon_root.extraMargin

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
