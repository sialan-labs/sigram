import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: contact_image
    width: 62
    height: 62

    property alias source: img.path
    property color borderColor: "#333333"

    property int uid

    Connections {
        target: Telegram
        onUserPhotoChanged: {
            if( user_id != uid )
                return
            img.path = Telegram.getPhotoPath(uid)
        }
        onChatPhotoChanged: {
            if( user_id != uid )
                return
            img.path = Telegram.getPhotoPath(uid)
        }
    }

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: width/2
        smooth: true
        visible: false
    }

    Image {
        id: img
        anchors.fill: parent
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectCrop
        smooth: true
        visible: false
        asynchronous: true
        source: path.length==0? "files/unknown.jpg" : "file://" + path

        property string path: Telegram.getPhotoPath(uid)
    }

    ThresholdMask {
        anchors.fill: img
        source: img
        maskSource: mask
        threshold: 0.4
        spread: 0.2
    }

    Rectangle {
        anchors.fill: parent
        radius: width/2
        smooth: true
        border.color: contact_image.borderColor
        border.width: 1
        color: "#00000000"
    }
}
