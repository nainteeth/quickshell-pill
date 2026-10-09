import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import ".."

ColumnLayout {
    id: root
    required property var node
    required property string title
    readonly property var audio: node?.audio ?? null
    spacing: 0

    PwObjectTracker {
        objects: root.node ? [root.node] : []
    }

    RowLayout {
        Layout.fillWidth: true
        PillLabel {
            Layout.fillWidth: true
            text: root.title
            font.weight: Font.Medium
        }
        PillLabel {
            text: root.audio ? Math.round(root.audio.volume * 100) + "%" : "—"
            color: root.audio?.muted ? Theme.muted : Theme.accent
            font.pixelSize: 12
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        ActionButton {
            iconName: root.audio?.muted ? "muted" : "volume"
            tooltip: root.audio?.muted ? "Unmute " + root.title : "Mute " + root.title
            enabled: !!root.audio && !!root.node?.ready
            highlighted: !!root.audio?.muted
            onClicked: root.audio.muted = !root.audio.muted
        }
        Slider {
            id: slider
            Layout.fillWidth: true
            implicitHeight: 26
            from: 0
            to: 1
            stepSize: 0.01
            wheelEnabled: true
            enabled: !!root.audio && !!root.node?.ready
            Accessible.name: root.title + " volume"
            onMoved: {
                root.audio.volume = value;
                if (value > 0)
                    root.audio.muted = false;
            }

            Binding {
                target: slider
                property: "value"
                value: root.audio?.volume ?? 0
                when: !slider.pressed
            }

            background: Rectangle {
                x: slider.leftPadding
                y: (slider.height - height) / 2
                width: slider.availableWidth
                height: 4
                radius: 3
                color: Theme.surface
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 3
                    color: root.audio?.muted ? Theme.muted : Theme.accent
                }
            }
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: (slider.height - height) / 2
                width: slider.pressed || slider.activeFocus ? 12 : 10
                height: width
                radius: width / 2
                color: Theme.text
                Behavior on width {
                    NumberAnimation {
                        duration: 100
                    }
                }
            }
        }
    }
}
