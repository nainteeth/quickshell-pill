import QtQuick
import Quickshell
import ".."
import "../components"

Item {
    id: root
    property bool active: true
    implicitWidth: row.implicitWidth
    implicitHeight: 20

    SystemClock {
        id: clock
        enabled: root.active
        precision: SystemClock.Minutes
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        PillLabel {
            height: root.implicitHeight
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.pixelSize: 17
            font.weight: Font.DemiBold
        }
        PillLabel {
            height: root.implicitHeight
            text: Qt.formatDateTime(clock.date, "ddd, d MMM yyyy")
            color: Theme.muted
            font.pixelSize: 12
        }
    }
}
