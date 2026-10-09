pragma Singleton

import QtQuick

QtObject {
    readonly property color background: "#161616"
    readonly property color surface: "#252525"
    readonly property color hover: "#363636"
    readonly property color text: "#ededed"
    readonly property color muted: "#969696"
    readonly property color accent: "#ededed"
    readonly property color accentSurface: "#303030"
    readonly property color error: "#ededed"
    readonly property string font: "Cantarell"
    readonly property int duration: 200
    readonly property int topMargin: 8
    readonly property int horizontalPadding: 12
    readonly property int verticalPadding: 8
}
