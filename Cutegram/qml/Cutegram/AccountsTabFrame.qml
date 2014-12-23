import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

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
        width: 48*Devices.density
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
            iconHeight: 26*Devices.density
            tooltipText: qsTr("New group chat")
            tooltipFont.family: AsemanApp.globalFontFamily
            tooltipFont.pixelSize: 9*Devices.fontDensity
            onClicked: {
                slide_menu.show(add_groupchat_component)
            }
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
            iconHeight: 22*Devices.density
            tooltipText: qsTr("New chat")
            tooltipFont.family: AsemanApp.globalFontFamily
            tooltipFont.pixelSize: 9*Devices.fontDensity
            onClicked: {
                slide_menu.show(add_userchat_component)
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
            iconHeight: 22*Devices.density
            tooltipText: qsTr("Configure")
            tooltipFont.family: AsemanApp.globalFontFamily
            tooltipFont.pixelSize: 9*Devices.fontDensity
        }
    }

    Component {
        id: account_component
        AccountFrame {
            anchors.fill: parent
            visible: true
            onUnreadCountChanged: refreshUnreadCounts()
        }
    }

    Component {
        id: add_userchat_component

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 237*Devices.density

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

    Component {
        id: add_groupchat_component

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 237*Devices.density

            LineEdit {
                id: topic_txt
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4*Devices.density
                placeholder: qsTr("Group Topic")
                pickerEnable: Devices.isTouchDevice
            }

            AccountContactList {
                id: contact_list
                anchors.top: topic_txt.bottom
                anchors.bottom: done_btn.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 4*Devices.density
                anchors.bottomMargin: 4*Devices.density
                telegram: accountView.telegramObject

                property variant accountView: hash.value(profiles.keys[0])
            }

            Button {
                id: done_btn
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                normalColor: masterPalette.highlight
                highlightColor: Qt.darker(masterPalette.highlight)
                textColor: masterPalette.highlightedText
                textFont.family: AsemanApp.globalFontFamily
                textFont.pixelSize: 9*Devices.fontDensity
                textFont.bold: false
                height: 40*Devices.density
                text: qsTr("Create")
                onClicked: {
                    var topic = topic_txt.text.trim()
                    if( topic.length == 0 )
                        return

                    slide_menu.end()
                    contact_list.telegram.messagesCreateChat(contact_list.selecteds, topic)
                }
            }
        }
    }

    function refreshUnreadCounts() {
        var keys = hash.keys()
        var counter = 0
        for( var i=0; i<keys.length; i++ ) {
            var acc = hash.value(keys[i])
            counter += acc.unreadCount
        }

        Cutegram.sysTrayCounter = counter
    }
}
