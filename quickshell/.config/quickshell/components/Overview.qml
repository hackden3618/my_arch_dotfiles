import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services"

// Native Quickshell workspace overview with per-window previews and drag/drop.
PanelWindow {
    id: overview

    readonly property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    readonly property var workspaceCards: buildWorkspaceCards()
    property int layer: 0
    property int selectedIndex: 0
    property var hoveredWindow: null

    function buildWorkspaceCards() {
        const all = Hyprland.workspaces.values;
        const cards = [];
        for (let id = 1; id <= 18; id++) {
            const workspace = all.find(w => w.id === id) || null;
            cards.push({ id: id, name: workspace ? workspace.name : String(id), workspace: workspace });
        }
        for (const workspace of all) {
            if (workspace.id < 0 && !workspace.name.startsWith("special:"))
                cards.push({ id: workspace.id, name: workspace.name, workspace: workspace });
        }
        return cards;
    }
    function windowsForWorkspace(id) {
        return Hyprland.toplevels.values.filter(w => w.workspace && w.workspace.id === id && w.address.length > 0);
    }
    function addressSelector(window) {
        return "address:" + window.address;
    }
    function dispatchLua(lua) {
        // `hl.dsp.*` only creates a dispatcher value; evaluate it through
        // hl.dispatch so the action actually runs in Hyprland's Lua config.
        Quickshell.execDetached(["hyprctl", "eval", "hl.dispatch(" + lua + ")"]);
    }
    function workspaceSelector(card) {
        return card.id < 0 ? card.name.replaceAll('"', '\\"') : String(card.id);
    }
    function focusWorkspace(card) {
        if (!card)
            return;
        dispatchLua('hl.dsp.focus({ workspace = "' + overview.workspaceSelector(card) + '" })');
        UiState.overviewOpen = false;
    }
    function focusWindow(window) {
        dispatchLua('hl.dsp.focus({ window = "' + addressSelector(window) + '" })');
        UiState.overviewOpen = false;
    }
    function closeWindow(window) {
        if (window && window.address)
            dispatchLua('hl.dsp.window.close({ window = "' + addressSelector(window) + '" })');
    }
    function closeHovered() {
        if (overview.hoveredWindow)
            overview.closeWindow(overview.hoveredWindow);
    }
    function moveWindow(window, card) {
        if (!window || !window.address || !card)
            return;
        dispatchLua('hl.dsp.window.move({ window = "' + addressSelector(window) + '", workspace = "' + overview.workspaceSelector(card) + '", follow = true })');
        UiState.overviewOpen = false;
    }
    function currentPageCards() {
        return overview.workspaceCards.slice(overview.layer * 9, overview.layer * 9 + 9);
    }
    function changeLayer(direction) {
        const count = Math.max(1, Math.ceil(overview.workspaceCards.length / 9));
        overview.layer = Math.max(0, Math.min(count - 1, overview.layer + direction));
        overview.selectedIndex = Math.min(overview.selectedIndex, Math.max(0, overview.currentPageCards().length - 1));
    }
    function moveLayer(direction) {
        if (direction === "left" || direction === "up")
            overview.changeLayer(-1);
        else if (direction === "right" || direction === "down")
            overview.changeLayer(1);
    }
    function activateSelected() {
        const cards = overview.currentPageCards();
        if (cards.length > 0)
            overview.focusWorkspace(cards[Math.min(overview.selectedIndex, cards.length - 1)]);
    }

    screen: overview.focusedScreen
    visible: UiState.overviewOpen || frame.opacity > 0.01
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "qs-overview"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: UiState.overviewOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: {
        if (UiState.overviewOpen) {
            const currentIndex = overview.workspaceCards.findIndex(card => card.workspace && card.workspace.focused);
            overview.layer = currentIndex >= 0 ? Math.floor(currentIndex / 9) : 0;
            overview.selectedIndex = currentIndex >= 0 ? currentIndex % 9 : 0;
            keys.forceActiveFocus();
        }
    }

    HyprlandFocusGrab {
        windows: [overview]
        active: UiState.overviewOpen
        onCleared: UiState.overviewOpen = false
    }

    Item {
        id: keys
        anchors.fill: parent
        focus: UiState.overviewOpen

        Keys.onPressed: event => {
            const count = overview.currentPageCards().length;
            if (event.key === Qt.Key_Escape) {
                UiState.overviewOpen = false;
            } else if (event.key === Qt.Key_PageDown) {
                overview.changeLayer(1);
            } else if (event.key === Qt.Key_PageUp) {
                overview.changeLayer(-1);
            } else if (event.key === Qt.Key_Left) {
                overview.selectedIndex = Math.max(0, overview.selectedIndex - 1);
            } else if (event.key === Qt.Key_Right) {
                overview.selectedIndex = Math.min(count - 1, overview.selectedIndex + 1);
            } else if (event.key === Qt.Key_Up) {
                overview.selectedIndex = Math.max(0, overview.selectedIndex - 3);
            } else if (event.key === Qt.Key_Down) {
                overview.selectedIndex = Math.min(count - 1, overview.selectedIndex + 3);
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                overview.activateSelected();
            } else if (event.key === Qt.Key_X) {
                overview.closeHovered();
            }
            event.accepted = true;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.scrim
        opacity: UiState.overviewOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.motionMedium; easing.type: Theme.easing } }
        MouseArea {
            anchors.fill: parent
            enabled: UiState.overviewOpen
            onClicked: UiState.overviewOpen = false
        }
    }

    Rectangle {
        id: frame
        anchors.centerIn: parent
        width: Math.min(parent.width - 72, 1560)
        height: Math.min(parent.height - 64, 920)
        radius: Theme.radiusPanel
        color: Theme.panel
        border.width: Theme.borderWidthStrong
        border.color: Theme.panelEdge
        opacity: UiState.overviewOpen ? 1 : 0
        scale: UiState.overviewOpen ? 1 : 0.96
        Behavior on opacity { NumberAnimation { duration: Theme.motionMedium; easing.type: Theme.easing } }
        Behavior on scale { NumberAnimation { duration: Theme.motionMedium; easing.type: Theme.easing } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 14
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Txt { text: "Workspaces"; size: 20; strong: true }
                    Txt { text: "Choose a workspace or drag a window to move it"; size: 11; color: Theme.muted }
                }
                Txt {
                    visible: overview.workspaceCards.length > 9
                    text: (overview.layer + 1) + " / " + Math.ceil(overview.workspaceCards.length / 9)
                    size: 12
                    strong: true
                    color: Theme.muted
                }
                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 18
                    color: dismissArea.containsMouse ? Theme.surfaceHigh : "transparent"
                    Glyph { anchors.fill: parent; text: ""; size: 14; color: Theme.muted }
                    MouseArea { id: dismissArea; anchors.fill: parent; hoverEnabled: true; onClicked: UiState.overviewOpen = false }
                }
            }

            GridLayout {
                id: workspaceGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 3
                rowSpacing: 14
                columnSpacing: 14

                Repeater {
                    model: overview.currentPageCards()
                    delegate: Rectangle {
                        id: workspaceCard
                        required property var modelData
                        required property int index
                        readonly property var windows: overview.windowsForWorkspace(workspaceCard.modelData.id)
                        readonly property bool current: workspaceCard.modelData.workspace ? workspaceCard.modelData.workspace.active : false
                        readonly property bool selected: overview.selectedIndex === workspaceCard.index

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 180
                        Layout.minimumHeight: 160
                        radius: Theme.radiusCard
                        color: workspaceCard.selected ? Theme.accentContainer : Theme.card
                        border.width: workspaceCard.selected ? Theme.borderWidthStrong : Theme.borderWidth
                        border.color: workspaceCard.selected || workspaceCard.current ? Theme.windowBorder : Theme.cardEdge
                        clip: true
                        Behavior on color { ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing } }
                        Behavior on border.color { ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing } }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            hoverEnabled: true
                            onEntered: overview.selectedIndex = workspaceCard.index
                            onClicked: overview.focusWorkspace(workspaceCard.modelData)
                        }

                        DropArea {
                            anchors.fill: parent
                            keys: ["qs-overview-window"]
                            onDropped: drop => {
                                if (drop.source && drop.source.windowData)
                                    overview.moveWindow(drop.source.windowData, workspaceCard.modelData);
                                drop.acceptProposedAction();
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 9

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Rectangle {
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28
                                    radius: 14
                                    color: workspaceCard.current ? Theme.accent : Theme.surfaceHigh
                                    Txt {
                                        anchors.fill: parent
                                        text: workspaceCard.modelData.name
                                        size: 11
                                        strong: true
                                        color: workspaceCard.current ? Theme.onAccent : Theme.fg
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                Txt {
                                    Layout.fillWidth: true
                                    text: workspaceCard.windows.length === 1 ? "1 window" : workspaceCard.windows.length + " windows"
                                    size: 10
                                    color: Theme.muted
                                }
                                Glyph {
                                    visible: workspaceCard.current
                                    text: ""
                                    size: 12
                                    color: Theme.accent
                                }
                                IconButton {
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: 30
                                    size: 30
                                    glyph: ""
                                    surfaceColor: workspaceCard.selected ? Theme.accentContainer : Theme.card
                                    onClicked: overview.focusWorkspace(workspaceCard.modelData)
                                }
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                columns: workspaceCard.windows.length > 1 ? 2 : 1
                                rowSpacing: 6
                                columnSpacing: 6

                                Repeater {
                                    model: workspaceCard.windows.slice(0, 2)
                                    delegate: Rectangle {
                                        id: windowTile
                                        required property var modelData
                                        property var windowData: modelData
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.minimumHeight: 52
                                        radius: Theme.radiusChip
                                        color: Theme.surfaceLow
                                        border.width: 1
                                        border.color: Theme.cardEdge
                                        clip: true
                                        Drag.active: windowDrag.active
                                        Drag.source: windowTile
                                        Drag.keys: ["qs-overview-window"]
                                        Drag.supportedActions: Qt.MoveAction

                                        ScreencopyView {
                                            id: preview
                                            anchors.fill: parent
                                            anchors.bottomMargin: titleStrip.height
                                            captureSource: windowTile.windowData.wayland
                                            constraintSize: Qt.size(640, 360)
                                            live: UiState.overviewOpen
                                            visible: hasContent
                                        }
                                        Item {
                                            anchors.fill: parent
                                            visible: !preview.hasContent
                                            Glyph {
                                                anchors.centerIn: parent
                                                text: "󰖯"
                                                size: 24
                                                color: Theme.muted
                                            }
                                        }
                                        Rectangle {
                                            id: titleStrip
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.bottom: parent.bottom
                                            height: 30
                                            color: Theme.mix(Theme.panel, Theme.ink, 0.18)
                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 8
                                                anchors.rightMargin: 6
                                                spacing: 6
                                                Image {
                                                    Layout.preferredWidth: 15
                                                    Layout.preferredHeight: 15
                                                    readonly property var entry: DesktopEntries.heuristicLookup(windowTile.windowData.wayland?.appId || windowTile.windowData.lastIpcObject?.class || "")
                                                    source: entry && entry.icon ? Quickshell.iconPath(entry.icon, "application-x-executable") : ""
                                                    sourceSize: Qt.size(30, 30)
                                                    fillMode: Image.PreserveAspectFit
                                                }
                                                Txt {
                                                    Layout.fillWidth: true
                                                    text: windowTile.windowData.title || windowTile.windowData.lastIpcObject?.class || "Window"
                                                    size: 10
                                                    color: Theme.textOn(parent.parent.color)
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onEntered: overview.hoveredWindow = windowTile.windowData
                                            onExited: if (overview.hoveredWindow === windowTile.windowData) overview.hoveredWindow = null
                                            onClicked: overview.focusWindow(windowTile.windowData)
                                        }
                                        DragHandler {
                                            id: windowDrag
                                            target: null
                                        }
                                        Rectangle {
                                            width: 25
                                            height: 25
                                            radius: 13
                                            anchors.top: parent.top
                                            anchors.right: parent.right
                                            anchors.margins: 5
                                            color: closeWindowArea.containsMouse ? Theme.danger : Theme.panel
                                            visible: overview.hoveredWindow === windowTile.windowData || windowDrag.active
                                            Glyph { anchors.fill: parent; text: ""; size: 10; color: Theme.textOn(parent.color) }
                                            MouseArea {
                                                id: closeWindowArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: overview.closeWindow(windowTile.windowData)
                                            }
                                        }
                                    }
                                }

                                Txt {
                                    visible: workspaceCard.windows.length === 0
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.columnSpan: 2
                                    text: "Empty workspace"
                                    size: 11
                                    color: Theme.muted
                                }
                                Txt {
                                    visible: workspaceCard.windows.length > 2
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.columnSpan: 2
                                    text: "+" + (workspaceCard.windows.length - 2) + " more"
                                    size: 10
                                    color: Theme.muted
                                }
                            }
                        }

                        Behavior on scale { NumberAnimation { duration: Theme.motionShort; easing.type: Theme.easing } }
                        scale: workspaceCard.selected ? 1 : 0.995
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Txt {
                    Layout.fillWidth: true
                    text: "← → ↑ ↓ navigate   ·   Enter switch   ·   drag a window to move   ·   X close hovered   ·   Esc dismiss"
                    size: 10
                    color: Theme.muted
                }
                RowLayout {
                    visible: overview.workspaceCards.length > 9
                    spacing: 8
                    IconButton { glyph: ""; onClicked: overview.changeLayer(-1) }
                    IconButton { glyph: ""; onClicked: overview.changeLayer(1) }
                }
            }
        }
    }
}
