import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../services"

// One shell-owned surface for every StatusNotifierItem menu. The menu entries
// still come from each app; only their presentation and navigation are shared.
PopupWindow {
    id: root

    property Item anchorItem
    property var menuHandle
    property string appTitle: "System tray"
    property string appIcon: ""
    property var menuStack: []
    readonly property var activeHandle: menuStack.length > 0 ? menuStack[menuStack.length - 1] : menuHandle
    readonly property string pageTitle: menuStack.length > 0 ? (menuStack[menuStack.length - 1].text || appTitle) : appTitle

    function openFor(item, anchor) {
        const wasVisible = root.visible;
        root.visible = false;
        root.anchorItem = anchor;
        root.menuHandle = item.menu;
        root.appTitle = item.title || item.tooltipTitle || item.id || "System tray";
        root.appIcon = item.icon || "";
        root.menuStack = [];
        if (wasVisible)
            Qt.callLater(() => root.visible = true);
        else
            root.visible = true;
    }
    function goBack() {
        root.menuStack = root.menuStack.slice(0, -1);
    }

    visible: false
    width: 292
    height: Math.min(444, Math.max(112, menuList.contentHeight + 74 + (menuStack.length > 0 ? 42 : 0)))
    color: "transparent"
    grabFocus: true
    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.margins.bottom: 8

    QsMenuOpener {
        id: menuOpener
        menu: root.activeHandle
    }

    Rectangle {
        id: surface
        anchors.fill: parent
        anchors.margins: 2
        radius: Theme.radiusPanel
        color: Theme.panel
        border.width: Theme.borderWidthStrong
        border.color: Theme.panelEdge
        clip: true
        focus: root.visible
        scale: root.visible ? 1 : 0.96
        opacity: root.visible ? 1 : 0
        Keys.onEscapePressed: event => {
            root.visible = false;
            event.accepted = true;
        }
        Behavior on scale { NumberAnimation { duration: Theme.motionShort; easing.type: Theme.easing } }
        Behavior on opacity { NumberAnimation { duration: Theme.motionShort; easing.type: Theme.easing } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Image {
                    visible: root.menuStack.length === 0 && root.appIcon.length > 0
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    source: root.appIcon
                    sourceSize: Qt.size(44, 44)
                    fillMode: Image.PreserveAspectFit
                }
                Txt {
                    Layout.fillWidth: true
                    text: root.pageTitle
                    size: 14
                    strong: true
                    elide: Text.ElideRight
                }
                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 14
                    color: closeArea.containsMouse ? Theme.surfaceHigh : "transparent"
                    Glyph {
                        anchors.fill: parent
                        text: ""
                        size: 12
                        color: Theme.muted
                    }
                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.visible = false
                    }
                }
            }

            Rectangle {
                visible: root.menuStack.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 34 : 0
                radius: Theme.radiusChip
                color: backArea.containsMouse ? Theme.surfaceHigh : Theme.surfaceLow
                Row {
                    anchors.centerIn: parent
                    spacing: 7
                    Glyph { text: ""; size: 11; color: Theme.onAccentContainer }
                    Txt { text: "Back"; size: 11; strong: true; color: Theme.onAccentContainer }
                }
                MouseArea {
                    id: backArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.goBack()
                }
            }

            ListView {
                id: menuList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                model: menuOpener.children
                boundsBehavior: Flickable.StopAtBounds
                delegate: Rectangle {
                    id: entryRow
                    required property var modelData
                    width: menuList.width
                    height: !modelData ? 0 : (modelData.isSeparator ? 9 : 38)
                    radius: Theme.radiusChip
                    color: !modelData || modelData.isSeparator || !rowArea.containsMouse ? "transparent" : Theme.surfaceHigh

                    Rectangle {
                        visible: !!entryRow.modelData && entryRow.modelData.isSeparator
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 7
                        anchors.rightMargin: 7
                        height: 1
                        color: Theme.cardEdge
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 9
                        spacing: 9
                        visible: !!entryRow.modelData && !entryRow.modelData.isSeparator
                        opacity: entryRow.modelData && entryRow.modelData.enabled ? 1 : 0.46

                        Image {
                            visible: !!entryRow.modelData.icon
                            Layout.preferredWidth: 17
                            Layout.preferredHeight: 17
                            source: entryRow.modelData.icon || ""
                            sourceSize: Qt.size(34, 34)
                            fillMode: Image.PreserveAspectFit
                        }
                        Glyph {
                            visible: !!entryRow.modelData.buttonType && entryRow.modelData.checkState === Qt.Checked
                            text: ""
                            size: 11
                            color: Theme.accent
                            Layout.preferredWidth: 17
                        }
                        Txt {
                            Layout.fillWidth: true
                            text: entryRow.modelData ? (entryRow.modelData.text || "") : ""
                            size: 12
                            color: Theme.textOn(Theme.panel)
                            elide: Text.ElideRight
                        }
                        Glyph {
                            visible: !!entryRow.modelData.hasChildren
                            text: ""
                            size: 10
                            color: Theme.muted
                        }
                    }

                    MouseArea {
                        id: rowArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !!entryRow.modelData && !entryRow.modelData.isSeparator && entryRow.modelData.enabled
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (entryRow.modelData.hasChildren) {
                                root.menuStack = root.menuStack.concat([entryRow.modelData]);
                            } else {
                                entryRow.modelData.triggered();
                                root.visible = false;
                            }
                        }
                    }
                    Behavior on color { ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing } }
                }
            }
        }
    }
}
