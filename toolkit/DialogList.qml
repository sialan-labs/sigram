import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"
import "../thirdparty"

ToolKit.TgRectangle {
    id: dlist

    property alias categories: dmodel.categories
    property alias currentIndex: listv.currentIndex

    property alias visibility: dmodel.visibility
    property alias sortFlag: dmodel.sortFlag

    property alias refreshing: dmodel.refreshing

    signal forwardRequest(variant inputPeer, int msgId)

    onCurrentPeerChanged: dlist.currentIndex = dmodel.indexOf(currentPeer)

    Telegram.DialogListModel {
        id: dmodel
        engine: dlist.engine
        messageTextMethod: function(msg, messageType) {
            var result = ""
            switch(messageType) {
            case Telegram.Enums.TypeTextMessage:
                result = msg.message
                break
            case Telegram.Enums.TypePhotoMessage:
                result = (msg.media.caption.length? msg.media.caption : qsTr("[Photo]"))
                break
            case Telegram.Enums.TypeDocumentMessage:
                result = (msg.media.caption.length? msg.media.caption : qsTr("[Document]"))
                break
            case Telegram.Enums.TypeStickerMessage:
                result = (msg.media.caption.length? msg.media.caption : qsTr("[Sticker]"))
                break
            case Telegram.Enums.TypeVideoMessage:
                result = (msg.media.caption.length? msg.media.caption : qsTr("[Video]"))
                break
            case Telegram.Enums.TypeAudioMessage:
                result = (msg.media.caption.length? msg.media.caption : qsTr("[Audio]"))
                break
            case Telegram.Enums.TypeAnimatedMessage:
                result = (msg.media.caption.length? msg.media.caption : qsTr("[Animated]"))
                break
            case Telegram.Enums.TypeContactMessage:
                result = (msg.media.caption.length? msg.media.caption : qsTr("[Contact]"))
                break
            case Telegram.Enums.TypeWebPageMessage:
                result = (msg.media.caption.length? msg.media.caption : qsTr("[Webpage]"))
                break
            case Telegram.Enums.TypeVenueMessage:
            case Telegram.Enums.TypeGeoMessage:
                result = (msg.media.caption.length? msg.media.caption : qsTr("[Geo]"))
                break;
            case Telegram.Enums.TypeActionMessage:
                result = (msg.media.caption.length? msg.media.caption : qsTr("[Action]"))
                break
            case Telegram.Enums.TypeUnsupportedMessage:
            default:
                result = (msg.media.caption.length? msg.media.caption : qsTr("[Unknown]"))
                break
            }
            return result
        }
    }

    Connections {
        target: dlist.engine
        onPeerActivated: {
            for(var i=0; i<dmodel.count; i++) {
                var key = dmodel.get(i, Telegram.DialogListModel.RolePeerHex)
                if(key == peerKey) {
                    dlist.currentIndex = i
                    dlist.currentPeer = dmodel.get(i, Telegram.DialogListModel.RolePeerItem)
                    break
                }
            }
        }
    }

    AsemanListView {
        id: listv
        anchors.fill: parent
        model: dmodel
        currentIndex: -1
        highlightMoveDuration: 0
        highlightMoveVelocity: -1
        clip: true
        move: Transition {
            NumberAnimation { properties: "y"; easing.type: Easing.OutCubic; duration: 300 }
        }
        displaced: Transition {
            NumberAnimation { properties: "y"; easing.type: Easing.OutCubic; duration: 300 }
        }
        delegate: DialogListItem {
            width: listv.width
            engine: dlist.engine
            onActive: {
                listv.currentIndex = index
                currentPeer = model.peer
            }
            onForwardRequest: {
                listv.currentIndex = index
                currentPeer = model.peer
                dlist.forwardRequest(inputPeer, msgId)
            }
            onClearHistoryRequest: clearHistory(inputPeer, true)
        }

        highlight: Rectangle {
            width: listv.width
            height: 64*Devices.density
            color: CutegramGlobals.foregroundColor
        }
    }

    NormalWheelScroll {
        flick: listv
    }

    PhysicalScrollBar {
        anchors.right: listv.right
        height: listv.height
        width: 6*Devices.density
        color: CutegramGlobals.baseColor
        scrollArea: listv
    }

    function clearHistory(inputPeer, justClear) {
        dmodel.clearHistory(inputPeer, justClear)
    }
}

