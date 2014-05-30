import QtQuick 2.0

Item {
    id: confg
    width: 100
    height: 62

    property int userId: Telegram.me

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

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 12
        height: 40

        Button {
            id: background_btn
            anchors.right: delete_btn.left
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            normalColor: "#33CCAD"
            highlightColor: "#3AE9C6"
            text: qsTr("Change Background")
            fontSize: 9*fontsScale
            onClicked: {
                var path = Gui.getOpenFile()
                if( path.length == 0 )
                    return

                Gui.background = path
            }
        }

        Button {
            id: delete_btn
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            width: visible? height : 0
            color: "#E65245"
            iconHeight: 12
            icon: "files/delete.png"
            visible: Gui.background.length != 0
            onClicked: Gui.background = ""
        }
    }
}
