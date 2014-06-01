import QtQuick 2.0

Item {
    id: u_conf
    width: 100
    height: 62

    property int userId

    signal backRequest()
    signal chatRequest( string uid )

    Keys.onEscapePressed: backRequest()

    onUserIdChanged: {
        notify.checked = Gui.isMuted(u_conf.userId)
    }

    Connections {
        target: Gui
        onMuted: {
            if( id != u_conf.userId )
                return

            notify.checked = Gui.isMuted(u_conf.userId)
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
    }

    Rectangle {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: -200
        height: 53
        color: imageBack? "#88cccccc" : "#555555"

        Button {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            height: parent.height
            icon: "files/back.png"
            text: qsTr("Back to conversation")
            normalColor: "#00000000"
            highlightColor: "#00000000"
            textColor: press? "#4098bf" : (imageBack? "#333333" : "#cccccc")
            iconHeight: 22
            fontSize: 11
            textFont.weight: Font.Light
            onClicked: u_conf.backRequest()
        }
    }

    ContactImage {
        id: cimg
        width: 128
        height: width
        anchors.left: parent.left
        anchors.top: header.bottom
        anchors.leftMargin: 50
        anchors.topMargin: 60
        uid: u_conf.userId
        onlineState: true
        borderColor: "#333333"
    }

    Text {
        id: fname
        anchors.top: cimg.top
        anchors.left: cimg.right
        anchors.leftMargin: 50
        font.pointSize: 18
        font.weight: Font.DemiBold
        font.family: globalNormalFontFamily
        color: "#333333"
        text: Telegram.contactFirstName(u_conf.userId)
    }

    Text {
        id: lname
        anchors.top: fname.top
        anchors.left: fname.right
        anchors.leftMargin: 10
        font.pointSize: 18
        font.weight: Font.DemiBold
        font.family: globalNormalFontFamily
        color: "#333333"
        text: Telegram.contactLastName(u_conf.userId)
    }

    Rectangle {
        id: name_splitter
        anchors.top: fname.bottom
        anchors.left: fname.left
        anchors.right: lname.right
        anchors.topMargin: 4
        height: 1
        color: "#4098bf"
    }

    Text {
        id: last_seen
        anchors.top: name_splitter.bottom
        anchors.left: fname.left
        anchors.topMargin: 4
        font.pointSize: 10
        font.weight: Font.Normal
        font.family: globalNormalFontFamily
        color: "#777777"
        text: Telegram.contactLastSeenText(u_conf.userId)
    }

    Button {
        id: chat_btn
        anchors.top: last_seen.bottom
        anchors.left: fname.left
        anchors.topMargin: 60
        normalColor: "#00000000"
        highlightColor: "#00000000"
        textColor: press? "#337fa2" : "#4098bf"
        textFont.weight: Font.Normal
        textFont.pointSize: 11
        textFont.underline: true
        text: qsTr("Send Message")
        onClicked: {
            u_conf.chatRequest(u_conf.userId)
            u_conf.backRequest()
        }
    }

    Button {
        id: secret_btn
        anchors.top: chat_btn.bottom
        anchors.left: fname.left
        anchors.topMargin: 10
        normalColor: "#00000000"
        highlightColor: "#00000000"
        textColor: press? "#50ab99" : "#33ccad"
        textFont.weight: Font.Normal
        textFont.pointSize: 11
        textFont.underline: true
        text: qsTr("Start Secret Chat")
    }

    Text {
        id: phone_label
        anchors.right: phone.left
        anchors.rightMargin: 20
        anchors.top: phone.top
        font.pointSize: 11
        font.family: globalNormalFontFamily
        color: "#888888"
        text: qsTr("Mobile Phone:")
    }

    Text {
        id: phone
        anchors.top: secret_btn.bottom
        anchors.left: fname.left
        anchors.topMargin: 60
        font.pointSize: 11
        font.family: globalNormalFontFamily
        color: "#333333"
        text: Telegram.contactPhone(u_conf.userId)
    }

    Text {
        id: notify_label
        anchors.right: phone.left
        anchors.rightMargin: 20
        anchors.verticalCenter: notify.verticalCenter
        font.pointSize: 11
        font.family: globalNormalFontFamily
        color: "#888888"
        text: qsTr("Notification:")
    }

    CheckBox {
        id: notify
        anchors.top: phone.bottom
        anchors.left: fname.left
        anchors.topMargin: 10
        onCheckedChanged: Gui.setMute( u_conf.userId, checked )
    }

    Button {
        id: background_btn
        anchors.top: notify.bottom
        anchors.left: fname.left
        anchors.topMargin: 50
        normalColor: "#00000000"
        highlightColor: "#00000000"
        textColor: Gui.background.length==0? (press? "#50ab99" : "#33ccad") : ( press? "#D04528" : "#ff5532" )
        textFont.weight: Font.Normal
        textFont.pointSize: 11
        textFont.underline: true
        text: Gui.background.length==0? qsTr("Change Background") : qsTr("Remove Background")
        visible: u_conf.userId == Telegram.me
        onClicked: {
            if( Gui.background.length != 0 ) {
                Gui.background = ""
                return
            }

            var path = Gui.getOpenFile()
            if( path.length == 0 )
                return

            Gui.background = path
        }
    }
}
