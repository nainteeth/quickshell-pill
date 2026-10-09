import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell.Networking
import ".."

ColumnLayout {
    id: root
    required property WifiNetwork network
    property bool active: true
    property bool needsPassword: false
    property string error: ""
    readonly property bool usesPsk: [WifiSecurityType.WpaPsk, WifiSecurityType.Wpa2Psk, WifiSecurityType.Sae].includes(network.security)
    spacing: 6

    onActiveChanged: {
        if (!active) {
            password.clear();
            needsPassword = false;
        }
    }

    function connectNetwork() {
        error = "";
        if (network.connected) {
            network.disconnect();
        } else if (!network.known && usesPsk) {
            needsPassword = !needsPassword;
        } else if (!network.known && ![WifiSecurityType.Open, WifiSecurityType.Owe].includes(network.security)) {
            error = "Set up this network in Settings first.";
        } else {
            network.connect();
        }
    }

    function submitPassword() {
        if (!password.text || network.stateChanging)
            return;
        error = "";
        network.connectWithPsk(password.text);
        password.clear();
        needsPassword = false;
    }

    Connections {
        target: root.network
        function onConnectionFailed(reason) {
            if (reason === ConnectionFailReason.NoSecrets && root.usesPsk) {
                root.needsPassword = true;
                root.error = "A valid password is required.";
            } else {
                root.error = "Could not connect: " + ConnectionFailReason.toString(reason);
            }
        }
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: 34

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: pointer.containsMouse ? Theme.hover : root.network.connected ? Theme.accentSurface : Theme.background
            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8
            Icon {
                name: "network"
                implicitWidth: 14
                implicitHeight: 14
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                PillLabel {
                    Layout.fillWidth: true
                    text: root.network.name || "Hidden network"
                }
                PillLabel {
                    text: root.network.stateChanging ? (root.network.state === ConnectionState.Disconnecting ? "Disconnecting…" : "Connecting…") : root.network.connected ? "Connected" : (root.network.known ? "Saved" : WifiSecurityType.toString(root.network.security))
                    color: root.network.connected ? Theme.accent : Theme.muted
                    font.pixelSize: 10
                }
            }
            PillLabel {
                text: Math.round(root.network.signalStrength * 100) + "%"
                color: Theme.muted
                font.pixelSize: 11
            }
        }

        MouseArea {
            id: pointer
            anchors.fill: parent
            hoverEnabled: true
            enabled: !root.network.stateChanging
            cursorShape: Qt.PointingHandCursor
            onClicked: root.connectNetwork()
        }
    }

    RowLayout {
        visible: root.needsPassword
        Layout.fillWidth: true
        spacing: 8
        TextField {
            id: password
            Layout.fillWidth: true
            implicitHeight: 28
            echoMode: TextInput.Password
            placeholderText: "Network password"
            placeholderTextColor: Theme.muted
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 12
            leftPadding: 12
            selectByMouse: true
            onAccepted: root.submitPassword()
            background: Rectangle {
                color: password.activeFocus ? Theme.hover : Theme.surface
                radius: 8
            }
        }
        ActionButton {
            text: "Connect"
            enabled: password.text.length > 0 && !root.network.stateChanging
            highlighted: true
            onClicked: root.submitPassword()
        }
    }

    PillLabel {
        visible: root.error !== ""
        Layout.fillWidth: true
        text: root.error
        color: Theme.error
        font.pixelSize: 11
        wrapMode: Text.WordWrap
    }
}
