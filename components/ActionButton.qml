import QtQuick
import QtQuick.Controls.Basic
import ".."

Button {
    id: root
    property string iconName: ""
    property string tooltip: ""

    implicitWidth: iconName ? 26 : Math.max(44, label.implicitWidth + 16)
    implicitHeight: 26
    padding: 0
    hoverEnabled: true
    Accessible.name: tooltip || text

    background: Rectangle {
        radius: height / 2
        color: root.down || root.hovered || root.activeFocus ? Theme.hover : root.highlighted ? Theme.accentSurface : Theme.surface
        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    contentItem: Item {
        Icon {
            anchors.centerIn: parent
            visible: root.iconName !== ""
            name: root.iconName || "apps"
            width: 14
            height: 14
        }
        PillLabel {
            id: label
            anchors.centerIn: parent
            visible: root.iconName === ""
            text: root.text
            color: root.enabled ? Theme.text : Theme.muted
            font.pixelSize: 11
            font.weight: Font.DemiBold
        }
    }

    ToolTip.visible: hovered && tooltip !== ""
    ToolTip.text: tooltip
    ToolTip.delay: 650
}
