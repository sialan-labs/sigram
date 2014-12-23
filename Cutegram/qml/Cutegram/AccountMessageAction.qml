import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

Item {
    id: message_action
    width: 100
    height: 62

    property Message message
    property MessageAction action: message.action
    property User user: telegramObject.user(action.userId)

    property real typeMessageActionEmpty: 0xb6aef7b0
    property real typeMessageActionChatDeletePhoto: 0x95e3fbef
    property real typeMessageActionChatCreate: 0xa6638b9a
    property real typeMessageActionChatEditTitle: 0xb5a1ce5a
    property real typeMessageActionChatEditPhoto: 0x7fcb13a8
    property real typeMessageActionGeoChatCreate: 0x6f038ebc
    property real typeMessageActionChatDeleteUser: 0xb2ae9b0c
    property real typeMessageActionChatAddUser: 0x5e3cfc4b
    property real typeMessageActionGeoChatCheckin: 0xc7d53de

    property bool hasAction: action.classType != typeMessageActionEmpty

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 30*Devices.density
        color: "#88000000"
        visible: hasAction

        Text {
            anchors.centerIn: parent
            font.family: AsemanApp.globalFontFamily
            font.pixelSize: 9*Devices.fontDensity
            color: "#ffffff"
            text: {
                var res = ""
                switch(action.classType) {
                case typeMessageActionChatCreate:
                    res += user.firstName + " " + user.lastName
                    res = res.trim()
                    res += " " + qsTr("created group")
                    break

                case typeMessageActionChatAddUser:
                    res += user.firstName + " " + user.lastName
                    res = res.trim()
                    res += " " + qsTr("added new user to group")
                    break

                case typeMessageActionChatEditTitle:
                    res += user.firstName + " " + user.lastName
                    res = res.trim()
                    res += " " + qsTr("edited chat title to ") + action.title
                    break

                case typeMessageActionChatEditPhoto:
                    res += user.firstName + " " + user.lastName
                    res = res.trim()
                    res += " " + qsTr("edited chat photo")
                    break

                case typeMessageActionChatDeletePhoto:
                    res += user.firstName + " " + user.lastName
                    res = res.trim()
                    res += " " + qsTr("deleted chat photo")
                    break

                case typeMessageActionEmpty:
                default:
                    break
                }

                return res
            }
        }
    }
}
