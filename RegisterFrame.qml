import QtQuick 2.0
import org.sialan.telegram 1.0

Item {
    id: register_frame
    width: 100
    height: 62

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 60
        spacing: 10

        Image {
            width: 100
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            sourceSize: Qt.size(width,height)
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: "files/icon.png"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 26
            font.family: globalNormalFontFamily
            font.weight: Font.Light
            color: "#333333"
            text: "Sigram"
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 20
        }

        RegisterFramePhone {
            id: phone
            anchors.left: parent.left
            anchors.right: parent.right
            height: 300
            visible: Telegram.waitAndGet == Enums.PhoneNumber
        }

        RegisterFrameCode {
            id: code
            anchors.left: parent.left
            anchors.right: parent.right
            visible: Telegram.waitAndGet == Enums.AuthCode
        }

        RegisterFrameUser {
            id: user
            anchors.left: parent.left
            anchors.right: parent.right
            visible: Telegram.waitAndGet == Enums.UserDetails
        }

        Indicator {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 200
            visible: Telegram.waitAndGet == Enums.CheckingState
            source: "files/indicator_light.png"
            onVisibleChanged: {
                if( visible )
                    start()
                else
                    stop()
            }
        }
    }
}
