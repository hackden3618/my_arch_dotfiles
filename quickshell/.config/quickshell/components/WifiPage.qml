import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../services"

// Wi-Fi: switch, nearby networks, connect / disconnect / forget.
ColumnLayout {
    id: page

    // network whose password box is open
    property string askSsid: ""

    spacing: 10

    // only scan while this page is on screen
    Binding {
        target: Net
        property: "active"
        value: page.visible
    }

    PageHeader {
        Layout.fillWidth: true
        title: "Wi-Fi"
        switchable: true
        checked: Sys.wifiOn
        onToggled: Sys.toggleWifi()
    }

    Txt {
        Layout.fillWidth: true
        visible: Net.status.length > 0
        text: Net.status
        size: 11
        color: Theme.danger
        wrapMode: Text.Wrap
    }

    Txt {
        Layout.fillWidth: true
        visible: !Sys.wifiOn
        text: "Wi-Fi is off"
        color: Theme.muted
    }

    Txt {
        Layout.fillWidth: true
        visible: Sys.wifiOn && Net.networks.length === 0
        text: Net.scanning ? "Looking for networks…" : "No networks found"
        color: Theme.muted
    }

    Flickable {
        Layout.fillWidth: true
        visible: Sys.wifiOn && Net.networks.length > 0
        implicitHeight: Math.min(list.implicitHeight, 340)
        contentHeight: list.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: list
            width: parent.width
            spacing: 6

            Repeater {
                model: Net.networks
                delegate: ColumnLayout {
                    id: item
                    required property var modelData
                    readonly property bool asking: page.askSsid === item.modelData.ssid
                    readonly property bool busy: Net.busySsid === item.modelData.ssid

                    Layout.fillWidth: true
                    spacing: 4

                    ListRow {
                        Layout.fillWidth: true
                        glyph: ""
                        glyphOpacity: 0.4 + 0.6 * Math.min(1, item.modelData.signal / 100)
                        title: item.modelData.ssid
                        subtitle: item.modelData.inUse ? "Connected" : (item.modelData.known ? "Saved" : (item.modelData.secure ? "Secured" : "Open"))
                        active: item.modelData.inUse
                        busy: item.busy

                        onClicked: {
                            if (item.modelData.inUse)
                                return;
                            if (item.modelData.secure && !item.modelData.known) {
                                page.askSsid = item.asking ? "" : item.modelData.ssid;
                            } else {
                                Net.connect(item.modelData.ssid, "");
                            }
                        }

                        Glyph {
                            visible: item.modelData.secure
                            text: ""
                            size: 12
                            color: Theme.muted
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Chip {
                            visible: item.modelData.inUse
                            text: "Disconnect"
                            onClicked: Net.disconnect(item.modelData.ssid)
                        }
                        Chip {
                            visible: item.modelData.known && !item.modelData.inUse
                            text: "Forget"
                            onClicked: Net.forget(item.modelData.ssid)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        visible: item.asking
                        spacing: 8

                        TextField {
                            id: pass
                            Layout.fillWidth: true
                            implicitHeight: 36
                            echoMode: TextInput.Password
                            placeholderText: "Password"
                            color: Theme.fg
                            placeholderTextColor: Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 12
                            leftPadding: 14
                            rightPadding: 14
                            background: Rectangle {
                                radius: 18
                                color: Theme.surface
                                border.width: Theme.borderWidth
                                border.color: pass.activeFocus ? Theme.windowBorder : Theme.edge

                                Behavior on border.color {
                                    ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
                                }
                            }
                            onVisibleChanged: {
                                if (visible)
                                    forceActiveFocus();
                                else
                                    text = "";
                            }
                            onAccepted: {
                                Net.connect(item.modelData.ssid, text);
                                page.askSsid = "";
                            }
                        }
                        IconButton {
                            primary: true
                            glyph: ""
                            onClicked: pass.accepted()
                        }
                    }
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Chip {
            text: Net.scanning ? "Scanning…" : "Rescan"
            onClicked: Net.scan()
        }
        Chip {
            text: "Advanced settings"
            onClicked: {
                UiState.ccOpen = false;
                Quickshell.execDetached(["nm-connection-editor"]);
            }
        }
        Item {
            Layout.fillWidth: true
        }
    }
}
