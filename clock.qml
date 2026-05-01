import "./Icon.qml"
import QtQuick
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Services.UPower
import Quickshell.Hyprland

PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true
    exclusionMode: ExclusionMode.Ignore
    implicitHeight: 400
    margins.top: 5

    id: root

    readonly property string iconFont: "Font Awesome 7 Free Solid"
    readonly property string bg: "#1a1a23"
    readonly property string bg_acc: "#2a2a40"
    readonly property string bg_acc1: "#36364a"

    readonly property bool critical: UPower.onBattery && bat.percentage <= 0.15
    readonly property bool charging: bat.changeRate > 0 && bat.percentage <= 0.95
    readonly property UPowerDevice bat: UPower.displayDevice

    property string shownTab: "collapsed"

    readonly property bool collapsed: shownTab == "collapsed"
    readonly property bool expanded: shownTab != "collapsed"

    component BatteryIcon: Icon {
        radius: 15
        color: critical ? "#d90030" : charging ? "#0aa530" : bg_acc

        text: {
            const A = [
                "\uf244",
                "\uf243",
                "\uf242",
                "\uf241",
                "\uf240",
            ]
            return A[Math.round(4 * bat.percentage)];
        }
    }
    
    color: "transparent"

    mask: Region {
        item: island
    }

    HyprlandFocusGrab {
        windows: [root]
        active: expanded

        onCleared: {
            shownTab = "collapsed"
        }
    }

    ClippingRectangle {
        id: island
        
        radius: 20
        color: bg
        anchors.horizontalCenter: parent.horizontalCenter

        height: expanded ? expandedContents.implicitHeight : collapsedContents.implicitHeight
        width: expanded ? expandedContents.implicitWidth : collapsedContents.implicitWidth

        focus: expanded

        Keys.onPressed: (event) => {
            if (event.key == Qt.Key_Escape) {
                shownTab = "collapsed"
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

        Item {
            id: collapsedContents
            anchors.centerIn: parent
            visible: collapsed
            implicitWidth: 200
            implicitHeight: 40

            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10

                text: "0"
                color: bg_acc
                textColor: "#d0d0e0"
                radius: 15
                font: ""
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
                anchors.rightMargin: 10
            }
        }

        Item {
            implicitWidth: 120 * 2 + 20 * 4 + 60
            implicitHeight: 120 * 2 + 20 + 2 * 20
            anchors.centerIn: parent
            id: expandedContents

            visible: shownTab == "controls"

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
                    color: bg_acc

                    Icon {
                        x: 20
                        y: 20
                        radius: 18
                        color: bg_acc1
                        text: ""
                        id: wifi_status_icon
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
                    color: bg_acc

                    BatteryIcon {
                        x: 20
                        y: 20
                        radius: 18
                    }

                    Text {
                        x: 20
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 20

                        text: Math.round(bat.percentage * 100) + "%"
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
                        color: bg_acc
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
                                color: bg_acc
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
                    implicitWidth: 120 * 2 + 20
                    implicitHeight: 120
                    radius: 14
                    color: bg_acc

                    Layout.columnSpan: 2

                    id: mpris_ctl

                    function player() {
                        return Mpris.players.values[0];
                    }

                    Text {
                        text: Mpris.players.values[0]?.trackTitle ?? "No MPRIS-enabled player"
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
                                    mpris_ctl.player().previous()
                                }
                            }

                            WrapperMouseArea {
                                Icon {
                                    radius: 20
                                    color: bg_acc1
                                    text: mpris_ctl.player().isPlaying ? "\uf04c" : "\uf04b"
                                }

                                onClicked: {
                                    mpris_ctl.player().togglePlaying()
                                }
                            }

                            WrapperMouseArea {
                                Icon {
                                    radius: 20
                                    color: bg_acc1
                                    text: "\uf101"
                                }

                                onClicked: {
                                    mpris_ctl.player().next()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: island
        enabled: collapsed
        visible: collapsed

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            shownTab = "controls"
        }
    }

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }
}
