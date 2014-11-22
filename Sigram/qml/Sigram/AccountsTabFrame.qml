import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

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

    Item {
        id: frame
        anchors.left: left_frame.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }

    SlideMenu {
        id: slide_menu
        anchors.fill: frame
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
            anchors.bottom: add_user_btn.top
            anchors.left: parent.left
            width: parent.width
            height: width
            normalColor: "#00000000"
            highlightColor: "#88339DCC"
            cursorShape: Qt.PointingHandCursor
            icon: "files/add_chat.png"
            iconHeight: 26*physicalPlatformScale
            tooltipText: qsTr("New group chat")
            tooltipFont.family: SApp.globalFontFamily
            tooltipFont.pixelSize: 9*fontsScale
        }

        Button {
            id: add_user_btn
            anchors.bottom: conf_btn.top
            anchors.left: parent.left
            width: parent.width
            height: width
            normalColor: "#00000000"
            highlightColor: "#88339DCC"
            cursorShape: Qt.PointingHandCursor
            icon: "files/add_user.png"
            iconHeight: 22*physicalPlatformScale
            tooltipText: qsTr("New chat")
            tooltipFont.family: SApp.globalFontFamily
            tooltipFont.pixelSize: 9*fontsScale
            onClicked: {
                slide_menu.item = add_userchat_component.createObject(slide_menu)
            }
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
            tooltipText: qsTr("Configure")
            tooltipFont.family: SApp.globalFontFamily
            tooltipFont.pixelSize: 9*fontsScale
        }
    }

    Component {
        id: account_component
        AccountFrame {
            anchors.fill: parent
            visible: true
        }
    }

    Component {
        id: add_userchat_component

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 237*physicalPlatformScale

            AccountContactList {
                anchors.fill: parent
                telegram: accountView.telegramObject
                onSelected: {
                    slide_menu.end()
                    accountView.view.currentDialog = telegram.fakeDialogObject(cid, false)
                }

                property variant accountView: hash.value(profiles.keys[0])
            }
        }
    }
}
