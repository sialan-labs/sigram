import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0
import QtGraphicalEffects 1.0
import "../awesome"
import "../thirdparty"
import "../globals"

MouseArea {
    id: marea
    acceptedButtons: Qt.LeftButton|Qt.RightButton

    signal contextMenuRequest()
    signal clickRequest()

    property alias source: grabber.item

    property real lastMouseX
    property real lastMouseY
    property bool clickBlocked

    property bool draggable: true

    property Message message
    property InputPeer fromPeer

    property alias urls: mime.urls

    ItemImageGrabber {
        id: grabber
        onImageChanged: {
            drag.imageData = grabber.image
            drag.start()
        }
    }

    MimeData {
        id: mime
        dataMap: {
            var res = {"cutegram/dragType": CutegramEnums.dragDataTypeMessage}
            res[CutegramEnums.dragDataMessageMsgId] = message? message.id : 0
            res[CutegramEnums.dragDataMessageChannelId] = fromPeer? fromPeer.channelId : 0
            res[CutegramEnums.dragDataMessageChatId] = fromPeer? fromPeer.chatId : 0
            res[CutegramEnums.dragDataMessageUserId] = fromPeer? fromPeer.userId : 0
            res[CutegramEnums.dragDataMessageClassType] = fromPeer? fromPeer.classType : 0
            res[CutegramEnums.dragDataMessageAccessHash] = fromPeer? fromPeer.accessHash : 0
            return res
        }
    }

    DragObject {
        id: drag
        mimeData: mime
        source: marea
//        hotSpot: Qt.point(20*Devices.density, 20*Devices.density)
    }

    onPressed: {
        if(mouse.buttons == Qt.RightButton) {
            contextMenuRequest()
            clickBlocked = true
        } else {
            lastMouseX = mouseX
            lastMouseY = mouseY
            clickBlocked = false
        }
    }

    onMouseXChanged: {
        var delta = Math.abs(mouseX - lastMouseX)
        if(delta > 5*Devices.density) {
            if(!clickBlocked && draggable) {
                drag.hotSpot = Qt.point(mouseX, mouseY)
                grabber.start()
                clickBlocked = true
            }
        }
    }

    onMouseYChanged: {
        var delta = Math.abs(mouseY - lastMouseY)
        if(delta > 5*Devices.density) {

        }
    }

    onReleased: {
        if(clickBlocked)
            return

        marea.clickRequest()
    }
}

