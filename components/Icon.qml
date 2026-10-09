import QtQuick

Item {
    id: root
    required property string name
    implicitWidth: 20
    implicitHeight: 20

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../icons/" + root.name + ".svg")
        sourceSize.width: width * Screen.devicePixelRatio
        sourceSize.height: height * Screen.devicePixelRatio
    }
}
