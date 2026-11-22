import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services"

// Toast stack, top-right under the bar. Hidden while the Control Center is
// open (the shade already shows everything).
PanelWindow {
    id: win

    readonly property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]

    screen: win.focusedScreen
    visible: Notifs.popups.length > 0 && !UiState.ccOpen
    color: "transparent"
    anchors {
        top: true
        right: true
    }
    margins {
        top: 56
        right: 12
    }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 420
    implicitHeight: Math.max(1, stack.implicitHeight)

    WlrLayershell.namespace: "qs-toasts"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    ColumnLayout {
        id: stack
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 12

        Repeater {
            model: Notifs.popups
            delegate: NotifCard {
                required property var modelData
                Layout.fillWidth: true
                toast: true
                notif: modelData
            }
        }
    }
}
