import QtQuick 2.0
import AsemanTools 1.0
import TelegramQmlLib 1.0
// import CutegramTypes 1.0

Rectangle {
    id: up_dlg
    height: base.height
    clip: true
    color: {
        var result = encrypted? Cutegram.currentTheme.headerSecretColor : Cutegram.currentTheme.headerColor
        return Qt.rgba(result.r, result.g, result.b, 1)
    }

    property Dialog currentDialog
    property bool encrypted: currentDialog.encrypted

    property bool inited: false

    signal addParticianRequest()

    UserPropertiesBase {
        id: base
        width: parent.width
        currentDialog: up_dlg.currentDialog
        onAddParticianRequest: acc_view.addParticianRequest()
    }

    Timer {
        id: destroy_timer
        interval: 400
        onTriggered: up_dlg.destroy()
    }

    function end() {
        inited = false
        destroy_timer.restart()
    }

    Component.onCompleted: {
        inited = true
        BackHandler.pushHandler(up_dlg, up_dlg.end)
    }
}
