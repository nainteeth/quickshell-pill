pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import ".."
import "../components"

Item {
    id: root
    required property var panelWindow
    property bool active: true
    readonly property int itemCount: SystemTray.items.values.length
    implicitWidth: itemCount ? Math.min(8, itemCount) * 30 - 2 : emptyLabel.implicitWidth
    implicitHeight: itemCount ? icons.implicitHeight : 20

    Flow {
        id: icons
        width: parent.width
        spacing: 2

        Repeater {
            model: SystemTray.items

            Rectangle {
                id: trayItem
                required property SystemTrayItem modelData
                width: 28
                height: 28
                radius: 8
                color: pointer.containsMouse || menuAnchor.visible ? Theme.hover : Theme.background

                function openMenu() {
                    if (!modelData.hasMenu)
                        return;
                    if (menuAnchor.visible) {
                        menuAnchor.close();
                        return;
                    }
                    const point = mapToItem(root.panelWindow.contentItem, 0, height + 8);
                    menuAnchor.anchor.rect = Qt.rect(point.x, point.y, width, 1);
                    menuAnchor.open();
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                QsMenuAnchor {
                    id: menuAnchor
                    menu: trayItem.modelData.menu
                    anchor.window: root.panelWindow
                    anchor.edges: Edges.Bottom
                    anchor.gravity: Edges.Bottom | Edges.Right
                }

                Connections {
                    target: root
                    function onActiveChanged() {
                        if (!root.active)
                            menuAnchor.close();
                    }
                }
                Component.onDestruction: menuAnchor.close()

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 18
                    source: trayItem.modelData.icon || Quickshell.iconPath("application-x-executable")
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        saturation: -1
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    visible: trayItem.modelData.status === Status.NeedsAttention
                    width: 3
                    height: 3
                    radius: 2
                    color: Theme.text
                }

                MouseArea {
                    id: pointer
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: event => {
                        if (event.button === Qt.RightButton) {
                            trayItem.openMenu();
                        } else if (event.button === Qt.MiddleButton) {
                            trayItem.modelData.secondaryActivate();
                        } else if (trayItem.modelData.onlyMenu) {
                            trayItem.openMenu();
                        } else {
                            trayItem.modelData.activate();
                        }
                    }
                    onWheel: event => {
                        const horizontal = Math.abs(event.angleDelta.x) > Math.abs(event.angleDelta.y);
                        trayItem.modelData.scroll(horizontal ? event.angleDelta.x : event.angleDelta.y, horizontal);
                    }
                }

                ToolTip.visible: pointer.containsMouse && !menuAnchor.visible
                ToolTip.text: modelData.tooltipTitle || modelData.title || modelData.id
                ToolTip.delay: 650
            }
        }
    }

    PillLabel {
        id: emptyLabel
        anchors.centerIn: parent
        visible: root.itemCount === 0
        text: "No tray apps"
        color: Theme.muted
    }
}
