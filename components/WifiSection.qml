pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import ".."

ColumnLayout {
    id: root
    required property WifiDevice device
    property bool active: true
    property bool showDeviceName: false
    readonly property var networks: device.networks.values
    spacing: 2

    Binding {
        target: root.device
        property: "scannerEnabled"
        value: root.active && Networking.wifiEnabled
        restoreMode: Binding.RestoreBindingOrValue
    }

    PillLabel {
        visible: root.showDeviceName
        text: "WI-FI · " + root.device.name
        color: Theme.muted
        font.pixelSize: 10
        font.letterSpacing: 1
    }

    Repeater {
        model: Networking.wifiEnabled ? root.device.networks : null
        WifiRow {
            required property var modelData
            Layout.fillWidth: true
            network: modelData
            active: root.active
        }
    }

    PillLabel {
        Layout.fillWidth: true
        visible: !Networking.wifiEnabled || root.networks.length === 0
        text: !Networking.wifiHardwareEnabled ? "Wi-Fi is blocked by the hardware switch." : !Networking.wifiEnabled ? "Wi-Fi is turned off." : "Looking for nearby networks…"
        color: Theme.muted
        font.pixelSize: 12
        wrapMode: Text.WordWrap
    }
}
