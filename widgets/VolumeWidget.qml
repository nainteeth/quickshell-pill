import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import ".."
import "../components"

Item {
    id: root
    implicitWidth: 296
    // PipeWire playback streams are sink inputs; capture streams are source outputs.
    readonly property var streams: Pipewire.nodes.values.filter(n => n.audio && n.isStream && n.isSink)
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            PillLabel {
                text: "Sound"
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
        }

        AudioRow {
            Layout.fillWidth: true
            node: Pipewire.defaultAudioSink
            title: node ? (node.description || node.nickname || "Speakers") : "No audio output"
        }

        PillLabel {
            text: "Applications"
            color: Theme.muted
            font.pixelSize: 12
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(apps.implicitHeight, 220)
            contentWidth: availableWidth
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                id: apps
                width: parent.width
                spacing: 8
                Repeater {
                    model: root.streams
                    AudioRow {
                        required property var modelData
                        Layout.fillWidth: true
                        node: modelData
                        title: node.properties["application.name"] || node.description || node.name
                    }
                }
                PillLabel {
                    Layout.fillWidth: true
                    visible: root.streams.length === 0
                    text: Pipewire.ready ? "No apps playing" : "Connecting to PipeWire…"
                    color: Theme.muted
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
