import "./Icon.qml"
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Services.UPower
import Quickshell.Services.Notifications
import Quickshell.Hyprland

//pragma ComponentBehaviour: Bound

PanelWindow {
    id: root
    anchors.top: true
    anchors.left: true
    anchors.right: true
    exclusionMode: ExclusionMode.Ignore
    implicitHeight: 400
    margins.top: 5

    readonly property string iconFont: "Font Awesome 7 Free Solid"
    readonly property string bg: "#1a1a23"
    readonly property string bg_acc: "#2a2a40"
    readonly property string bg_acc1: "#36364a"

    property string shownTab: "collapsed"

    readonly property bool collapsed: shownTab == "collapsed"
    readonly property bool expanded: shownTab != "collapsed"

    component BatteryIcon: Icon {
        radius: 15
        color: critical ? "#d90030" : charging ? "#0aa530" : defaultColor

        property string defaultColor: root.bg_acc

        readonly property bool critical: UPower.onBattery && bat.percentage <= 0.152
        readonly property bool charging: bat.changeRate > 10 && bat.percentage <= 0.952
        readonly property UPowerDevice bat: UPower.displayDevice

        text: {
            const A = ["\uf244", "\uf243", "\uf242", "\uf241", "\uf240",];
            return A[Math.round(4 * bat.percentage)];
        }
    }

    MouseArea {
        anchors.fill: island
        enabled: root.collapsed
        visible: root.collapsed

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.shownTab = "controls";
        }
    }

    color: "transparent"

    mask: Region {
        item: island
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.expanded

        onCleared: {
            root.shownTab = "collapsed";
        }
    }

    NotificationServer {
        id: notifications

        onNotification: notification => {
            notification.tracked = true;
        }
    }

    ClippingRectangle {
        id: island

        radius: 20
        color: root.bg
        anchors.horizontalCenter: parent.horizontalCenter

        height: island_stack.height
        width: island_stack.width

        focus: root.expanded

        Keys.onPressed: event => {
            if (event.key == Qt.Key_Escape) {
                root.shownTab = "collapsed";
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutExpo
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutExpo
            }
        }

        StackLayout {
            id: island_stack
            anchors.centerIn: parent

            currentIndex: {
                if (root.shownTab == "collapsed")
                    return 0;
                else if (root.shownTab == "controls")
                    return 1;
                else if (root.shownTab == "notifications")
                    return 2;
            }

            // Idk why we need this here
            height: children[currentIndex].implicitHeight
            width: children[currentIndex].implicitWidth

            Item {
                id: collapsedContents
                implicitWidth: 200
                implicitHeight: 40

                SystemClock {
                    id: clock
                    precision: SystemClock.Minutes
                }

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 5

                    id: thing

                    readonly property int count: notifications.trackedNotifications.values.length
                    text: count
                    color: root.bg_acc
                    textColor: "#d0d0e0"
                    radius: 15
                    font: ""

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            root.shownTab = "notifications"
                            console.log(notifications.trackedNotifications.values.length);
                            //thing.count += 1;
                        }
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 15

                    Text {
                        font.pixelSize: 15
                        color: "white"

                        text: Qt.formatDateTime(clock.date, "HH:mm")
                    }
                }

                BatteryIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                }
            }

            Item {
                id: expandedContents
                implicitWidth: 120 * 2 + 20 * 4 + 60
                implicitHeight: 120 * 2 + 20 + 2 * 20

                GridLayout {
                    id: grid
                    columns: 3
                    anchors.centerIn: parent
                    rowSpacing: 20
                    columnSpacing: 20

                    Rectangle {
                        implicitWidth: 120
                        implicitHeight: 120
                        radius: 15
                        color: root.bg_acc

                        Icon {
                            id: wifi_status_icon
                            x: 20
                            y: 20
                            radius: 18
                            color: root.bg_acc1
                            text: ""
                            inverted: true
                        }

                        Text {
                            x: 20
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 20

                            font.pixelSize: 16
                            color: "white"
                            text: "eduroam"
                        }
                    }

                    Rectangle {
                        implicitWidth: 120
                        implicitHeight: 120
                        radius: 15
                        color: root.bg_acc

                        BatteryIcon {
                            x: 20
                            y: 20
                            radius: 18

                            defaultColor: root.bg_acc1
                        }

                        Text {
                            x: 20
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 20

                            text: Math.round(UPower.displayDevice.percentage * 100) + "%"
                            font.pixelSize: 16
                            color: "white"
                        }
                    }

                    WrapperMouseArea {
                        Layout.rowSpan: 2

                        onClicked: {
                            Pipewire.defaultAudioSink.audio.volume = (height - mouseY) / height;
                        }
                        onPositionChanged: {
                            Pipewire.defaultAudioSink.audio.volume = (height - mouseY) / height;
                        }

                        ClippingRectangle {
                            implicitWidth: 60
                            implicitHeight: 120 * 2 + 20
                            color: root.bg_acc
                            radius: 15

                            ClippingRectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right

                                implicitHeight: (Pipewire.defaultAudioSink?.audio.volume ?? 0) * parent.height

                                color: "white"

                                Text {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottomMargin: 10
                                    text: "\uf028"
                                    color: root.bg_acc
                                    font.pixelSize: 16
                                    font.family: root.iconFont
                                }
                            }
                            Text {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 10
                                text: "\uf028"
                                color: "white"
                                z: -1
                                font.pixelSize: 16
                                font.family: root.iconFont
                            }
                        }
                    }

                    Rectangle {
                        id: mpris_ctl
                        implicitWidth: 120 * 2 + 20
                        implicitHeight: 120
                        radius: 14
                        color: root.bg_acc

                        Layout.columnSpan: 2

                        function player() {
                            return Mpris.players.values[0];
                        }

                        Text {
                            text: {
                                let a = Mpris.players.values[0];

                                if (a === undefined)
                                    return "No MPRIS-enabled player"
                                else if (a.playbackState == MprisPlaybackState.Stopped)
                                    return "Stopped"
                                else
                                    return a.trackTitle
                            }

                            font.pixelSize: 16
                            y: 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "white"
                        }

                        WrapperItem {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 20

                            RowLayout {
                                visible: mpris_ctl.player() !== undefined

                                spacing: 20

                                WrapperMouseArea {
                                    Icon {
                                        radius: 20
                                        color: "#36364a"
                                        text: "\uf100"
                                    }

                                    onClicked: {
                                        mpris_ctl.player().previous();
                                    }
                                }

                                WrapperMouseArea {
                                    Icon {
                                        radius: 20
                                        color: root.bg_acc1
                                        text: mpris_ctl.player()?.isPlaying ? "\uf04c" : "\uf04b"
                                    }

                                    onClicked: {
                                        mpris_ctl.player().togglePlaying();
                                    }
                                }

                                WrapperMouseArea {
                                    Icon {
                                        radius: 20
                                        color: root.bg_acc1
                                        text: "\uf101"
                                    }

                                    onClicked: {
                                        mpris_ctl.player().next();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                implicitWidth: 400
                implicitHeight: 400

                Text {
                    y: 50
                    anchors.horizontalCenter: parent.horizontalCenter

                    visible: notifications.trackedNotifications.values.length == 0

                    text: "No notifications :)"

                    color: "white"
                    font.pixelSize: 20
                }

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 20

                    ListView {
                        //model: notifications.trackedNotifications
                        model: notifications.trackedNotifications
                        anchors.fill: parent

                        spacing: 20
                        orientation: Qt.Vertical

                        delegate: Rectangle {
                            implicitWidth: 360
                            implicitHeight: 110
                            radius: 15
                            color: root.bg_acc

                            id: deleg

                            required property Notification modelData

                            ColumnLayout {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.margins: 10

                                Text {
                                    color: "white"
                                    font.pixelSize: 18

                                    text: deleg.modelData.summary
                                }

                                Text {
                                    color: "white"
                                    text: deleg.modelData.body
                                }
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    deleg.modelData.dismiss()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
}
