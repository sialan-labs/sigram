import QtQuick 2.0

Item {
    width: 100
    height: 62

    property bool isPhoto: Telegram.messageIsPhoto(msgId)
    property int msgId

    Connections {
        target: Telegram
        onMsgFileDownloading: {
            if( msg_id != msgId )
                return

            p_bar.percent = percent
            p_bar.visible = true
            f_indicator.start()
        }
        onMsgFileDownloaded: {
            if( msg_id != msgId )
                return

            p_bar.visible = false
            f_indicator.stop()
            f_img.path = Telegram.messageMediaFile(msgId)
        }
    }

    Image {
        id: f_img
        anchors.fill: parent
        sourceSize: Qt.size(width,height)
        fillMode: Image.PreserveAspectCrop
        clip: true
        source: path.length==0? "" : "file://" + path

        property string path: Telegram.messageMediaFile(msgId)
    }

    Indicator {
        id: f_indicator
        anchors.fill: parent
    }

    Text {
        id: not_support_text
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        wrapMode: Text.WordWrap
        text: qsTr("Video and Audio files not supported yet.")
        visible: !Telegram.messageIsPhoto(msgId)
    }

    ProgressBar {
        id: p_bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: false
        height: 5
        color: "#88333333"

        Behavior on percent {
            NumberAnimation{ easing.type: Easing.Linear; duration: 1000 }
        }
    }

    MouseArea {
        anchors.fill: parent
        visible: f_img.path.length != 0
        onClicked: Gui.openFile(f_img.path)
    }
}
