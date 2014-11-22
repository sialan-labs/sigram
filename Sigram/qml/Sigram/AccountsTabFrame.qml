import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0

Rectangle {
    id: acc_tab_frame
    width: 100
    height: 62
    color: backColor0

    Connections {
        target: profiles
        onKeysChanged: refresh()
        Component.onCompleted: refresh()

        function refresh() {
            for( var i=0; i<profiles.count; i++ ) {
                var key = profiles.keys[i]
                if( hash.containt(key) )
                    continue

                var item = profiles.get(key)
                var acc = account_component.createObject(frame, {"accountItem": item})
                hash.insert(key, acc)
            }

            var hashKeys = hash.keys()
            for( var j=0; j>hashKeys.length; i++ ) {
                var key = hashKeys[j]
                if( profiles.containt(key) )
                    continue

                var acc = hash.value(key)
                acc.destroy()

                hash.remove(key)
            }
        }
    }

    HashObject {
        id: hash
    }

    Rectangle {
        id: left_frame
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 48*physicalPlatformScale
        color: masterPalette.highlight

        Image {
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            height: width
            sourceSize: Qt.size(width,height)
            source: "files/framed_icon.png"
            smooth: true
        }

        Button {
            id: add_chat_btn
            anchors.bottom: add_btn.top
            anchors.left: parent.left
            width: parent.width
            height: width
            normalColor: "#00000000"
            highlightColor: "#88339DCC"
            cursorShape: Qt.PointingHandCursor
            icon: "files/add_chat.png"
            iconHeight: 26*physicalPlatformScale
        }

        Button {
            id: add_btn
            anchors.bottom: conf_btn.top
            anchors.left: parent.left
            width: parent.width
            height: width
            normalColor: "#00000000"
            highlightColor: "#88339DCC"
            cursorShape: Qt.PointingHandCursor
            icon: "files/add_dialog.png"
            iconHeight: 16*physicalPlatformScale
        }

        Button {
            id: conf_btn
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.width
            height: width
            normalColor: "#00000000"
            highlightColor: "#88339DCC"
            cursorShape: Qt.PointingHandCursor
            icon: "files/configure.png"
            iconHeight: 22*physicalPlatformScale
        }
    }

    Item {
        id: frame
        anchors.left: left_frame.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }

    Component {
        id: account_component
        AccountFrame {
            anchors.fill: parent
            visible: true
        }
    }
}
