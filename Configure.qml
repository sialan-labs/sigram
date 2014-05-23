import QtQuick 2.0

Item {
    id: confg
    width: 100
    height: 62

    property int userId

    Connections {
        target: Telegram
        onContactsChanged: {
            confg.userId = Telegram.me()
        }
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 32
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        ContactImage {
            id: cimg
            width: 148
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            uid: confg.userId
            onlineState: true
            borderColor: "#cccccc"
        }

        Text {
            id: fname
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 14
            color: "#ffffff"
            text: Telegram.contactFirstName(confg.userId)
        }

        Text {
            id: lname
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 14
            color: "#ffffff"
            text: Telegram.contactLastName(confg.userId)
        }

        Text {
            id: phone
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 14
            color: "#ffffff"
            text: Telegram.contactPhone(confg.userId)
        }
    }
}
