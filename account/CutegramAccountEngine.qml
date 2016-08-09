import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtQuick.Controls 1.3
import "../globals"

AccountEngine {
    id: tgEngine

    property ApplicationWindow window
    property Notification notificationManager

    property alias typing: status.typing
    property alias unreadCount: notifyHandler.unreadCount

    signal peerActivated(string peerKey)

    HashObject {
        id: notificationsHash
    }

    Connections {
        target: notificationManager
        onNotifyAction: {
            var peerKey = notificationsHash.value(id)
            if(peerKey == null)
                return
            if(action == "0") {
                window.visible = true
                window.requestActivate()
                tgEngine.peerActivated(peerKey)
            }
            else
            if(action == "1") {

            }
        }
    }

    Telegram.Status {
        id: status
        engine: tgEngine
        online: window && (window.active || window.visible)
    }

    Telegram.NotificationHandler {
        id: notifyHandler
        engine: tgEngine
        onNewMessage: {
            if(window && window.active && window.visible)
                return
            if(!CutegramSettings.notifications)
                return

            var nid = notificationManager.sendNotify(title, message, "", 0, 3000,
                                                     [0, qsTr("Show"), 1, qsTr("Mute")])
            notificationsHash.insert(nid, peerKey)
        }
    }

    function openFile(path) {
        var newPath = tempPath + "/" + Tools.fileName(path) + "." + Tools.fileSuffix(path)
        Tools.copy(path, newPath)
        Qt.openUrlExternally(Devices.localFilesPrePath + newPath)
    }
}

