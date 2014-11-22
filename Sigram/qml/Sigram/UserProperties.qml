import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0
import QtGraphicalEffects 1.0

Item {
    id: up_dlg
    clip: true

    property bool inited: false
    property Dialog currentDialog

    property variant blurSource
    property real blurTopMargin: 0

    property alias color: frame.color

    MouseArea {
        anchors.fill: parent
        onClicked: end()
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: inited? 0.4 : 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: inited? base.height : 0
        clip: true

        Behavior on height {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        FastBlur {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: blurTopMargin
            height: blurSource.height
            source: blurSource
            radius: 64
        }

        Rectangle {
            id: frame
            anchors.fill: parent
            color: "#88ffffff"
        }

        MouseArea {
            anchors.fill: parent
            onWheel: wheel.accepted = true
        }

        UserPropertiesBase {
            id: base
            width: parent.width
            currentDialog: up_dlg.currentDialog
        }
    }

    Timer {
        id: destroy_timer
        interval: 400
        onTriggered: up_dlg.destroy()
    }

    function end() {
        inited = false
        destroy_timer.restart()
    }

    Component.onCompleted: BackHandler.pushHandler(up_dlg, up_dlg.end)
}
