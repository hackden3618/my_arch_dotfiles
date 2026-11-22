import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services"

// Volume / brightness / mute indicator, bottom centre, click-through.
PanelWindow {
    id: win

    readonly property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    readonly property bool isMute: UiState.osdKind === "mute"
    readonly property bool isBright: UiState.osdKind === "brightness"

    screen: win.focusedScreen
    visible: UiState.osdVisible || body.opacity > 0.01
    color: "transparent"
    anchors {
        bottom: true
    }
    margins {
        bottom: 80
    }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 380
    implicitHeight: 56
    mask: Region {}

    WlrLayershell.namespace: "qs-osd"
    WlrLayershell.layer: WlrLayer.Overlay

    Rectangle {
        id: body
        anchors.fill: parent
        radius: Theme.radiusPanel
        color: Theme.panel
        border.width: Theme.borderWidth
        border.color: win.isMute ? Theme.danger : Theme.panelEdge
        opacity: UiState.osdVisible ? 1 : 0
        scale: UiState.osdVisible ? 1 : 0.94

        Behavior on opacity {
            NumberAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
        }
        Behavior on color {
            ColorAnimation { duration: Theme.motionLong; easing.type: Theme.easing }
        }
        Behavior on border.color {
            ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 14

            Glyph {
                text: win.isMute ? "" : (win.isBright ? "" : "")
                color: win.isMute ? Theme.danger : Theme.fg
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 8
                radius: 4
                color: Qt.alpha(Theme.fg, 0.16)

                Rectangle {
                    height: 8
                    radius: 4
                    width: parent.width * Math.max(0, Math.min(1, UiState.osdValue))
                    color: Theme.accent

                    Behavior on width {
                        NumberAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
                    }
                }
            }

            Txt {
                text: win.isMute ? "Muted" : Math.round(UiState.osdValue * 100) + "%"
                strong: true
                color: win.isMute ? Theme.danger : Theme.fg
            }
        }
    }
}
