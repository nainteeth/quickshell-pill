pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "widgets"

PanelWindow {
    id: root

    property bool open: false
    property string widget: "clock"
    property string displayedWidget: "clock"
    property real reveal: open ? 1 : 0
    readonly property Item loadedWidget: content.item
    signal dismissed

    anchors.top: true
    implicitWidth: Math.min(500, screen ? screen.width : 500)
    implicitHeight: Math.min(640, screen ? screen.height : 640)
    visible: open || reveal > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-pill"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // Only the visible pill receives pointer events; the rest passes through.
    mask: Region {
        x: pill.x
        y: pill.y
        width: root.open ? pill.width : 0
        height: root.open ? pill.height : 0
        radius: pill.radius
    }

    Behavior on reveal {
        NumberAnimation {
            duration: Theme.duration
            easing.type: Easing.OutCubic
        }
    }

    onWidgetChanged: {
        displayedWidget = widget;
        if (visible)
            swap.restart();
    }

    NumberAnimation {
        id: swap
        target: content
        property: "offset"
        from: 6
        to: 0
        duration: Theme.duration
        easing.type: Easing.OutCubic
    }

    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        y: -height + (height + Theme.topMargin) * root.reveal
        width: Math.min(root.width - 24, (root.loadedWidget?.implicitWidth ?? 180) + Theme.horizontalPadding * 2)
        height: Math.min(root.height - Theme.topMargin - 16, (root.loadedWidget?.implicitHeight ?? 20) + Theme.verticalPadding * 2)
        radius: Math.min(18, height / 2)
        color: Theme.background
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: Theme.duration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Theme.duration
                easing.type: Easing.OutCubic
            }
        }

        Loader {
            id: content
            property real offset: 0
            x: Theme.horizontalPadding
            y: Theme.verticalPadding + offset
            width: pill.width - Theme.horizontalPadding * 2
            height: pill.height - Theme.verticalPadding * 2
            enabled: root.open && !swap.running
            focus: true
            Keys.onEscapePressed: root.dismissed()
            sourceComponent: {
                switch (root.displayedWidget) {
                case "network":
                    return network;
                case "tray":
                    return tray;
                case "volume":
                    return volume;
                default:
                    return clock;
                }
            }
        }
    }

    Component {
        id: clock
        ClockWidget {
            active: root.open
        }
    }
    Component {
        id: network
        NetworkWidget {
            active: root.open
        }
    }
    Component {
        id: volume
        VolumeWidget {}
    }
    Component {
        id: tray
        TrayWidget {
            panelWindow: root
            active: root.open
        }
    }
}
