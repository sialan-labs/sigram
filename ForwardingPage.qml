import QtQuick 2.0

Rectangle {
    width: 100
    height: 62
    color: "#66ffffff"

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        ContactImage {
            id: fwd_contact
            width: 92
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            uid: Telegram.messageFromId(forwarding)
            onlineState: true
        }

        Text {
            id: fwd_txt
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pointSize: 11
            font.family: globalTextFontFamily
            color: "#333333"
            text: Telegram.messageBody(forwarding)
        }

        Text {
            id: fwd_info
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 10
            font.weight: Font.Normal
            font.family: globalNormalFontFamily
            color: "#333333"
            text: qsTr("Please select a contact...")
            visible: forwardTo==0
        }

        Item {
            id: fwd_to_frame
            anchors.left: parent.left
            anchors.right: parent.right
            height: forwardTo==0? 0 : fwd_to_column.height + 30
            opacity: forwardTo==0? 0 : 1
            visible: opacity != 0
            clip: true

            Behavior on height {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }
            Behavior on opacity {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            Column {
                id: fwd_to_column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                    wrapMode: Text.WordWrap
                    font.pointSize: 18
                    font.weight: Font.Normal
                    font.family: globalTextFontFamily
                    color: "#333333"
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("To")
                }

                ContactImage {
                    id: fwd_to_contact
                    width: 92
                    height: width
                    anchors.horizontalCenter: parent.horizontalCenter
                    uid: forwardTo
                    onlineState: true
                }

                Text {
                    wrapMode: Text.WordWrap
                    font.pointSize: 11
                    font.weight: Font.Normal
                    font.family: globalTextFontFamily
                    color: "#333333"
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Telegram.dialogTitle(forwardTo)
                }
            }
        }
    }

    Button {
        anchors.right: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.margins: 8
        height: 40
        width: 100
        normalColor: "#ff5532"
        highlightColor: "#D04528"
        textColor: "#ffffff"
        text: qsTr("Cancel")
        onClicked: {
            forwardTo = 0
            forwarding = 0
        }
    }

    Button {
        anchors.left: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.margins: 8
        height: 40
        width: 100
        normalColor: forwardTo==0? "#888888" : "#33ccad"
        highlightColor: forwardTo==0? "#888888" :"#50ab99"
        textColor: "#ffffff"
        text: qsTr("Forward")
        onClicked: {
            if( forwardTo == 0 )
                return

            Telegram.forwardMessage( forwarding, forwardTo )
            forwardTo = 0
            forwarding = 0
        }
    }
}
