pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import ".."
import "../components"

Item {
    id: root
    property bool active: true
    readonly property var devices: Networking.devices.values
    readonly property bool hasWifi: devices.some(d => d.type === DeviceType.Wifi)
    readonly property string notice: {
        if (Networking.backend === NetworkBackendType.None)
            return "NetworkManager is unavailable";
        switch (Networking.connectivity) {
        case NetworkConnectivity.Portal:
            return "Sign in to this network in your browser";
        case NetworkConnectivity.Limited:
            return "Limited internet access";
        default:
            return "";
        }
    }
    implicitWidth: 296
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            PillLabel {
                Layout.fillWidth: true
                text: "Network"
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
            ActionButton {
                visible: root.hasWifi
                text: Networking.wifiEnabled ? "Wi-Fi on" : "Wi-Fi off"
                highlighted: Networking.wifiEnabled
                enabled: Networking.wifiHardwareEnabled
                tooltip: Networking.wifiHardwareEnabled ? "Toggle Wi-Fi" : "Wi-Fi is blocked by the hardware switch"
                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
            }
            ActionButton {
                iconName: "more"
                tooltip: "Network settings"
                onClicked: Quickshell.execDetached(["nm-connection-editor"])
            }
        }

        PillLabel {
            Layout.fillWidth: true
            visible: root.notice !== ""
            text: root.notice
            color: Theme.muted
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(deviceList.implicitHeight, 260)
            contentWidth: availableWidth
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                id: deviceList
                width: parent.width
                spacing: 6

                Repeater {
                    model: root.devices
                    Loader {
                        id: deviceLoader
                        required property var modelData
                        Layout.fillWidth: true
                        sourceComponent: modelData.type === DeviceType.Wifi ? wireless : wired

                        Component {
                            id: wireless
                            WifiSection {
                                device: deviceLoader.modelData
                                active: root.active
                                showDeviceName: root.devices.filter(d => d.type === DeviceType.Wifi).length > 1
                            }
                        }
                        Component {
                            id: wired
                            RowLayout {
                                spacing: 8
                                Icon {
                                    name: "ethernet"
                                    implicitWidth: 14
                                    implicitHeight: 14
                                }
                                PillLabel {
                                    Layout.fillWidth: true
                                    text: "Ethernet"
                                }
                                PillLabel {
                                    text: deviceLoader.modelData.connected ? "Connected" : "Disconnected"
                                    color: Theme.muted
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }

                PillLabel {
                    Layout.fillWidth: true
                    visible: root.devices.length === 0
                    text: "No network adapters"
                    color: Theme.muted
                }
            }
        }
    }
}
