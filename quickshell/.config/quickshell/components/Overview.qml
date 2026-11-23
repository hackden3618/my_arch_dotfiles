import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services"

// Workspace overview, Hyprtasking-style: one column per workspace with live
// window previews. Click a workspace to switch, click a preview to focus that
// window, drag a preview onto another workspace to move it.
PanelWindow {
    id: overview

    readonly property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    readonly property int focusedWorkspaceId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1

    // The bar is built around five workspaces, but this overview scales to as
    // many as you create. Existing workspaces are shown, plus 1-5 by default.
    // More than ten workspaces are split into pages of ten.
    readonly property var cards: {
        const all = Hyprland.workspaces.values;
        let highest = 0;
        for (const workspace of all) {
            if (workspace.id > 0 && workspace.id <= 99)
                highest = Math.max(highest, workspace.id);
        }
        const count = Math.max(5, highest);
        const list = [];
        for (let id = 1; id <= count; id++) {
            let found = null;
            for (const workspace of all) {
                if (workspace.id === id) {
                    found = workspace;
                    break;
                }
            }
            list.push({ id: id, workspace: found });
        }
        return list;
    }
    readonly property int pageSize: 10
    readonly property int pageCount: Math.max(1, Math.ceil(overview.cards.length / overview.pageSize))
    property int page: 0
    readonly property var pageCards: overview.cards.slice(overview.page * overview.pageSize, overview.page * overview.pageSize + overview.pageSize)
    readonly property int columns: Math.min(5, overview.pageCards.length)
    readonly property int rows: Math.ceil(overview.pageCards.length / 5)
    readonly property int maxTiles: overview.rows === 1 ? 3 : 2
    readonly property real panelHeight: overview.rows === 1 ? 620 : 760

    property int selectedIndex: 0
    property var hoveredWindow: null

    function windowsForWorkspace(id) {
        return Hyprland.toplevels.values.filter(w => w.workspace && w.workspace.id === id && w.address.length > 0);
    }
    function appIdFor(window) {
        if (!window)
            return "";
        return (window.wayland && window.wayland.appId) || (window.lastIpcObject && window.lastIpcObject.class) || "";
    }
    function titleFor(window) {
        if (!window)
            return "";
        return window.title || (window.lastIpcObject && window.lastIpcObject.class) || "Window";
    }
    function iconFor(window) {
        const appId = overview.appIdFor(window);
        const entry = appId ? DesktopEntries.heuristicLookup(appId) : null;
        return entry && entry.icon ? Quickshell.iconPath(entry.icon, "application-x-executable") : "";
    }
    function runLua(lua) {
        // hl.dsp.* only builds a dispatcher. Evaluate it through hl.dispatch so
        // the action actually runs. Window selectors must be real window
        // objects, not "address:..." strings.
        Quickshell.execDetached(["hyprctl", "eval", lua]);
    }
    function focusWorkspace(card) {
        if (!card)
            return;
        overview.runLua('hl.dispatch(hl.dsp.focus({ workspace = "' + card.id + '" }))');
        UiState.overviewOpen = false;
    }
    function focusIndex(index) {
        if (index >= 0 && index < overview.pageCards.length)
            overview.focusWorkspace(overview.pageCards[index]);
    }
    function focusWindow(window) {
        if (!window || !window.address)
            return;
        overview.runLua('local w = hl.get_window("address:' + window.address + '"); if w then hl.dispatch(hl.dsp.focus({ window = w })) end');
        UiState.overviewOpen = false;
    }
    function closeWindow(window) {
        if (!window || !window.address)
            return;
        overview.runLua('local w = hl.get_window("address:' + window.address + '"); if w then hl.dispatch(hl.dsp.window.close({ window = w })) end');
        if (overview.hoveredWindow === window)
            overview.hoveredWindow = null;
    }
    function closeHovered() {
        if (overview.hoveredWindow)
            overview.closeWindow(overview.hoveredWindow);
    }
    function moveWindow(window, card) {
        if (!window || !window.address || !card)
            return;
        overview.runLua('local w = hl.get_window("address:' + window.address + '"); if w then hl.dispatch(hl.dsp.window.move({ window = w, workspace = "' + card.id + '", follow = true })) end');
        UiState.overviewOpen = false;
    }
    function moveActiveTo(card) {
        const active = Hyprland.activeToplevel;
        if (active && active.address)
            overview.moveWindow(active, card);
    }
    function activateSelected() {
        if (overview.pageCards.length > 0)
            overview.focusWorkspace(overview.pageCards[Math.max(0, Math.min(overview.selectedIndex, overview.pageCards.length - 1))]);
    }
    function changePage(direction, selectLast) {
        const next = Math.max(0, Math.min(overview.pageCount - 1, overview.page + direction));
        if (next === overview.page)
            return;
        overview.page = next;
        const nextCount = Math.min(overview.pageSize, overview.cards.length - next * overview.pageSize);
        overview.selectedIndex = selectLast ? Math.max(0, nextCount - 1) : 0;
        pageAnim.restart();
    }

    screen: overview.focusedScreen
    visible: UiState.overviewOpen || panel.opacity > 0.01
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "qs-overview"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: UiState.overviewOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: {
        if (UiState.overviewOpen) {
            const index = overview.cards.findIndex(card => card.id === overview.focusedWorkspaceId);
            const safeIndex = index >= 0 ? index : 0;
            overview.page = Math.floor(safeIndex / overview.pageSize);
            overview.selectedIndex = safeIndex % overview.pageSize;
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
            const count = overview.pageCards.length;
            if (count === 0)
                return;
            if (event.key === Qt.Key_Escape) {
                UiState.overviewOpen = false;
            } else if (event.key === Qt.Key_Left) {
                if (overview.selectedIndex > 0)
                    overview.selectedIndex--;
                else if (overview.page > 0)
                    overview.changePage(-1, true);
            } else if (event.key === Qt.Key_Right) {
                if (overview.selectedIndex < count - 1)
                    overview.selectedIndex++;
                else if (overview.page < overview.pageCount - 1)
                    overview.changePage(1, false);
            } else if (event.key === Qt.Key_Up) {
                const step = overview.rows > 1 ? overview.columns : 1;
                overview.selectedIndex = Math.max(0, overview.selectedIndex - step);
            } else if (event.key === Qt.Key_Down) {
                const step = overview.rows > 1 ? overview.columns : 1;
                overview.selectedIndex = Math.min(count - 1, overview.selectedIndex + step);
            } else if (event.key === Qt.Key_Tab) {
                if (overview.selectedIndex < count - 1)
                    overview.selectedIndex++;
                else if (overview.page < overview.pageCount - 1)
                    overview.changePage(1, false);
            } else if (event.key === Qt.Key_Backtab) {
                if (overview.selectedIndex > 0)
                    overview.selectedIndex--;
                else if (overview.page > 0)
                    overview.changePage(-1, true);
            } else if (event.key === Qt.Key_PageDown) {
                overview.changePage(1, false);
            } else if (event.key === Qt.Key_PageUp) {
                overview.changePage(-1, false);
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                overview.activateSelected();
            } else if (event.key === Qt.Key_X) {
                overview.closeHovered();
            } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                overview.focusIndex(event.key - Qt.Key_1);
            } else if (event.key === Qt.Key_0) {
                overview.focusIndex(9);
            }
            event.accepted = true;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.scrim
        opacity: UiState.overviewOpen ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
        }

        MouseArea {
            anchors.fill: parent
            enabled: UiState.overviewOpen
            onClicked: UiState.overviewOpen = false
        }
    }

    // Soft accent halo behind the panel. No blur dependency: a low-alpha ring
    // gives the edge a gentle lift against the wallpaper.
    Rectangle {
        anchors.fill: panel
        anchors.margins: -2
        radius: panel.radius + 2
        color: "transparent"
        border.width: 2
        border.color: Qt.alpha(Theme.accent, 0.12)
        opacity: panel.opacity
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: Math.min(parent.width - 96, 1400)
        height: Math.min(parent.height - 72, overview.panelHeight)
        radius: Theme.radiusPanel
        color: Theme.panel
        border.width: Theme.borderWidth
        border.color: Theme.panelEdge
        opacity: UiState.overviewOpen ? 1 : 0
        scale: UiState.overviewOpen ? 1 : 0.97

        Behavior on height {
            NumberAnimation { duration: Theme.motionMedium; easing.type: Theme.easingEmphasized }
        }
        Behavior on opacity {
            NumberAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.motionLong; easing.type: Theme.easingEmphasized }
        }

        // Faint top light, like a glass surface catching the wallpaper.
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0; color: Theme.mix(Theme.panel, Theme.white, 0.045) }
                GradientStop { position: 0.42; color: Theme.panel }
            }
        }
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 22
            height: 1
            color: Qt.alpha(Theme.white, 0.055)
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Txt {
                        text: "Workspaces"
                        size: 24
                        strong: true
                    }
                    Txt {
                        text: "Click to switch · drag a window to move · right-click sends the focused window"
                        size: 11
                        color: Theme.muted
                    }
                }

                Rectangle {
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: countLabel.implicitWidth + 20
                    radius: 14
                    color: Theme.surfaceLow
                    border.width: 1
                    border.color: Theme.cardEdge

                    Txt {
                        id: countLabel
                        anchors.centerIn: parent
                        text: overview.cards.length + (overview.cards.length === 1 ? " workspace" : " workspaces")
                        size: 10
                        strong: true
                        color: Theme.muted
                    }
                }

                IconButton {
                    size: 32
                    glyph: ""
                    onClicked: UiState.overviewOpen = false
                }
            }

            GridLayout {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: overview.columns
                rowSpacing: 14
                columnSpacing: 14

                transform: Translate { id: gridShift }

                Repeater {
                    model: overview.pageCards
                    delegate: Rectangle {
                        id: workspaceCard

                        required property var modelData
                        required property int index

                        readonly property var wins: overview.windowsForWorkspace(workspaceCard.modelData.id)
                        readonly property bool current: overview.focusedWorkspaceId === workspaceCard.modelData.id
                        readonly property bool selected: overview.selectedIndex === workspaceCard.index
                        readonly property bool hovered: cardHover.hovered || dropArea.containsDrag
                        readonly property color ink: Theme.textOn(workspaceCard.color)
                        readonly property string countLabel: workspaceCard.wins.length === 0
                            ? "Empty"
                            : workspaceCard.wins.length + (workspaceCard.wins.length === 1 ? " window" : " windows")

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 170
                        Layout.minimumHeight: 220
                        radius: Theme.radiusCard
                        color: workspaceCard.current
                            ? Theme.accentContainer
                            : (workspaceCard.hovered || workspaceCard.selected ? Theme.surfaceHigh : Theme.card)
                        border.width: workspaceCard.current ? 2 : (workspaceCard.selected ? 1.5 : 1)
                        border.color: workspaceCard.current
                            ? Theme.windowBorder
                            : (workspaceCard.hovered || workspaceCard.selected ? Theme.accentEdge : Theme.cardEdge)
                        scale: cardMouse.pressed ? 0.985 : (workspaceCard.hovered ? 1.012 : 1)

                        Behavior on color {
                            ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
                        }
                        Behavior on border.color {
                            ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
                        }
                        Behavior on scale {
                            NumberAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
                        }

                        HoverHandler {
                            id: cardHover
                        }

                        MouseArea {
                            id: cardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onEntered: overview.selectedIndex = workspaceCard.index
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton)
                                    overview.moveActiveTo(workspaceCard.modelData);
                                else
                                    overview.focusWorkspace(workspaceCard.modelData);
                            }
                        }

                        DropArea {
                            id: dropArea
                            anchors.fill: parent
                            keys: ["qs-overview-window"]
                            onEntered: overview.selectedIndex = workspaceCard.index
                            onDropped: drop => {
                                if (drop.source && drop.source.windowData)
                                    overview.moveWindow(drop.source.windowData, workspaceCard.modelData);
                                drop.accept(Qt.MoveAction);
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28
                                    radius: 14
                                    color: workspaceCard.current ? Theme.accent : Theme.surfaceHigh

                                    Txt {
                                        anchors.centerIn: parent
                                        text: workspaceCard.modelData.id
                                        size: 11
                                        strong: true
                                        color: workspaceCard.current ? Theme.onAccent : Theme.fg
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0

                                    Txt {
                                        Layout.fillWidth: true
                                        text: workspaceCard.current ? "Active" : "Workspace " + workspaceCard.modelData.id
                                        size: 11
                                        strong: true
                                        color: workspaceCard.ink
                                    }
                                    Txt {
                                        Layout.fillWidth: true
                                        text: workspaceCard.countLabel
                                        size: 9
                                        color: Theme.mutedOn(workspaceCard.color)
                                    }
                                }

                                Glyph {
                                    visible: workspaceCard.current
                                    text: ""
                                    size: 11
                                    color: Theme.accent
                                }
                            }

                            Item {
                                id: preview
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                readonly property real tileHeight: Math.min(
                                    preview.width * 0.5625,
                                    (preview.height - (overview.maxTiles - 1) * 8) / overview.maxTiles
                                )

                                Column {
                                    anchors.centerIn: parent
                                    width: parent.width
                                    spacing: 8

                                    Repeater {
                                        model: workspaceCard.wins.slice(0, overview.maxTiles)
                                        delegate: Rectangle {
                                            id: windowTile

                                            required property var modelData
                                            required property int index

                                            property var windowData: modelData
                                            readonly property bool hovered: tileHover.hovered
                                            readonly property string iconSource: overview.iconFor(windowTile.windowData)

                                            width: preview.width
                                            height: preview.tileHeight
                                            radius: Theme.radiusChip
                                            clip: true
                                            color: Theme.surfaceLow
                                            border.width: 1
                                            border.color: windowTile.hovered ? Theme.accentEdge : Theme.cardEdge
                                            scale: tileMouse.pressed ? 0.99 : (windowTile.hovered ? 1.008 : 1)
                                            opacity: tileDrag.active ? 0.35 : 1

                                            Behavior on border.color {
                                                ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
                                            }
                                            Behavior on scale {
                                                NumberAnimation { duration: Theme.motionFast; easing.type: Theme.easing }
                                            }
                                            Behavior on opacity {
                                                NumberAnimation { duration: Theme.motionFast; easing.type: Theme.easing }
                                            }

                                            HoverHandler {
                                                id: tileHover
                                            }

                                            ScreencopyView {
                                                id: capture
                                                anchors.fill: parent
                                                captureSource: windowTile.windowData.wayland
                                                constraintSize: Qt.size(640, 360)
                                                live: UiState.overviewOpen
                                                visible: hasContent
                                            }

                                            Rectangle {
                                                anchors.fill: parent
                                                visible: !capture.hasContent
                                                color: Theme.mix(Theme.surfaceLow, Theme.ink, 0.12)

                                                Column {
                                                    anchors.centerIn: parent
                                                    spacing: 4

                                                    Image {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        width: 28
                                                        height: 28
                                                        source: windowTile.iconSource
                                                        sourceSize: Qt.size(56, 56)
                                                        fillMode: Image.PreserveAspectFit
                                                        visible: source.toString() !== ""
                                                    }
                                                    Glyph {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        visible: windowTile.iconSource === ""
                                                        text: "󰖯"
                                                        size: 24
                                                        color: Theme.muted
                                                    }
                                                    Txt {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        width: Math.min(implicitWidth, preview.width - 24)
                                                        text: overview.titleFor(windowTile.windowData)
                                                        size: 9
                                                        color: Theme.muted
                                                        horizontalAlignment: Text.AlignHCenter
                                                        elide: Text.ElideRight
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                anchors.bottom: parent.bottom
                                                height: 30
                                                gradient: Gradient {
                                                    GradientStop { position: 0; color: Qt.rgba(0, 0, 0, 0) }
                                                    GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0.72) }
                                                }

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 7
                                                    anchors.rightMargin: 7
                                                    spacing: 5

                                                    Image {
                                                        Layout.preferredWidth: 13
                                                        Layout.preferredHeight: 13
                                                        source: windowTile.iconSource
                                                        sourceSize: Qt.size(26, 26)
                                                        fillMode: Image.PreserveAspectFit
                                                        visible: source.toString() !== ""
                                                    }
                                                    Txt {
                                                        Layout.fillWidth: true
                                                        text: overview.titleFor(windowTile.windowData)
                                                        size: 9
                                                        color: Theme.snow
                                                        elide: Text.ElideRight
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                id: tileMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                acceptedButtons: Qt.LeftButton
                                                cursorShape: Qt.PointingHandCursor
                                                onEntered: overview.hoveredWindow = windowTile.windowData
                                                onExited: if (overview.hoveredWindow === windowTile.windowData) overview.hoveredWindow = null
                                                onClicked: overview.focusWindow(windowTile.windowData)
                                            }

                                            Rectangle {
                                                width: 22
                                                height: 22
                                                radius: 11
                                                anchors.top: parent.top
                                                anchors.right: parent.right
                                                anchors.margins: 5
                                                color: closeArea.containsMouse ? Theme.danger : Qt.alpha(Theme.ink, 0.55)
                                                opacity: windowTile.hovered || tileDrag.active ? 1 : 0

                                                Behavior on opacity {
                                                    NumberAnimation { duration: Theme.motionFast; easing.type: Theme.easing }
                                                }

                                                Glyph {
                                                    anchors.fill: parent
                                                    text: ""
                                                    size: 9
                                                    color: Theme.snow
                                                }

                                                MouseArea {
                                                    id: closeArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: overview.closeWindow(windowTile.windowData)
                                                }
                                            }

                                            Rectangle {
                                                visible: windowTile.index === overview.maxTiles - 1 && workspaceCard.wins.length > overview.maxTiles
                                                anchors.left: parent.left
                                                anchors.top: parent.top
                                                anchors.margins: 5
                                                width: moreText.implicitWidth + 10
                                                height: 18
                                                radius: 9
                                                color: Qt.alpha(Theme.ink, 0.75)

                                                Txt {
                                                    id: moreText
                                                    anchors.centerIn: parent
                                                    text: "+" + (workspaceCard.wins.length - overview.maxTiles)
                                                    size: 9
                                                    strong: true
                                                    color: Theme.snow
                                                }
                                            }

                                            DragHandler {
                                                id: tileDrag
                                                target: null
                                            }

                                            Drag.active: tileDrag.active
                                            Drag.source: windowTile
                                            Drag.hotSpot: Qt.point(windowTile.width / 2, windowTile.height / 2)
                                            Drag.keys: ["qs-overview-window"]
                                            Drag.dragType: Drag.Internal
                                        }
                                    }
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    visible: workspaceCard.wins.length === 0

                                    Glyph {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "󰍹"
                                        size: 30
                                        color: Theme.mutedOn(workspaceCard.color)
                                    }
                                    Txt {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Empty"
                                        size: 11
                                        strong: true
                                        color: workspaceCard.ink
                                    }
                                    Txt {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Click to switch"
                                        size: 9
                                        color: Theme.mutedOn(workspaceCard.color)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ParallelAnimation {
                id: pageAnim
                NumberAnimation {
                    target: grid
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Theme.motionMedium
                    easing.type: Theme.easing
                }
                NumberAnimation {
                    target: gridShift
                    property: "x"
                    from: 22
                    to: 0
                    duration: Theme.motionMedium
                    easing.type: Theme.easingEmphasized
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                KeyHint { keys: "← →"; label: "navigate" }
                KeyHint { keys: "↵"; label: "switch" }
                KeyHint { keys: "1–9"; label: "jump" }
                KeyHint { keys: "X"; label: "close window" }
                KeyHint { keys: "Esc"; label: "dismiss" }
                KeyHint {
                    visible: overview.pageCount > 1
                    keys: "PgUp PgDn"
                    label: "page"
                }

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    visible: overview.pageCount > 1
                    spacing: 6

                    IconButton {
                        size: 26
                        glyph: ""
                        opacity: overview.page > 0 ? 1 : 0.35
                        onClicked: overview.changePage(-1, false)
                    }
                    Txt {
                        text: (overview.page + 1) + " / " + overview.pageCount
                        size: 10
                        strong: true
                        color: Theme.muted
                    }
                    IconButton {
                        size: 26
                        glyph: ""
                        opacity: overview.page < overview.pageCount - 1 ? 1 : 0.35
                        onClicked: overview.changePage(1, false)
                    }
                }

                Txt {
                    text: {
                        const card = overview.pageCards[overview.selectedIndex];
                        return card ? "Workspace " + card.id + " of " + overview.cards.length : "";
                    }
                    size: 10
                    color: Theme.muted
                }
            }
        }
    }
}
