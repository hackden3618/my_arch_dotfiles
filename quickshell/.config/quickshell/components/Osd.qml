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
    visible: UiState.osdVisible
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
        anchors.fill: parent
        radius: 28
        color: Theme.panel
        border.width: 1
        border.color: win.isMute ? Theme.danger : Theme.panelEdge

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
                    color: win.isBright ? Theme.warm : Theme.accent

                    Behavior on width {
                        NumberAnimation { duration: 80 }
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
