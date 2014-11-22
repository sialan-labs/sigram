import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Item {
    width: 300*physicalPlatformScale
    height: 400*physicalPlatformScale

    property alias currentDialog: cp_model.dialog

    ChatParticipantsModel {
        id: cp_model
        telegram: telegramObject
        onRefreshingChanged: {
            if( refreshing )
                indicator.start()
            else
                indicator.stop()
        }
    }

    Indicator {
        id: indicator
        anchors.centerIn: parent
        light: false
        modern: true
        indicatorSize: 20*physicalPlatformScale
    }

    GridView {
        id: list
        anchors.fill: parent
        model: cp_model
        cellWidth: width/Math.floor(width/92*physicalPlatformScale)
        cellHeight: 92*physicalPlatformScale
        clip: true
        delegate: Item {
            width: list.cellWidth
            height: list.cellHeight

            property ChatParticipant cpItem: item
            property User user: telegramObject.user(cpItem.userId)

            Image {
                anchors.top: parent.top
                anchors.bottom: txt.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: height
                sourceSize: Qt.size(width,height)
                fillMode: Image.PreserveAspectCrop
                source: imgPath.length==0? "files/user.png" : imgPath

                property string imgPath: user.photo.photoSmall.download.location
            }

            Text {
                id: txt
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 1
                text: user.firstName + " " + user.lastName
            }
        }
    }

    NormalWheelScroll {
        flick: list
    }

    ScrollBar {
        scrollArea: list; height: list.height; width: 6*physicalPlatformScale
        anchors.right: list.right; anchors.top: list.top; color: textColor0; forceVisible: true
    }

    Indicator {
        anchors.centerIn: parent
    }
}
