import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import TelegramQml 1.0
import QtMultimedia 5.0

Rectangle {
    id: acc_frame
    width: 100
    height: 62
    color: "#333333"

    property ProfilesModelItem accountItem
    property AccountView view
    property alias telegramObject: telegram
    property alias unreadCount: telegram.unreadCount
    property int notifyTimeOut: Devices.isWindows? 5000 : 3000

    property bool isActive: {
        if(view && view.windowsCount!=0)
            return true
        else
            return View.active && View.visible
    }

    signal activeRequest()
    signal addParticianRequest()

    onIsActiveChanged: {
        var status = View.visible
        if(view && view.windowsCount!=0) {
            status = true
        }

        telegram.online = status
    }

    QtObject {
        id: privates
    }

    HashObject {
        id: notifies_hash
    }

    MediaPlayer {
        id: sound_notify
        source: Cutegram.messageAudio
        autoLoad: false
    }

    Notification {
        id: notification
        color: titleBarColor
        onNotifyClosed: notifies_hash.remove(id)
        onNotifyAction: {
            var notifyData = notifies_hash.value(id)
            if( action == notifyActShow ) {
                if( view )
                    view.showDialog( notifyData.id? telegram.messageDialog(notifyData.id) : telegram.dialog(notifyData) )
            } else
            if( action == notifyActMute ) {
                if( !view )
                    return

                var dId = notifyData.id? telegram.messageDialogId(notifyData.id) : notifyData
                telegram.userData.addMute(dId)
            }
        }

        property int notifyActShow: 0
        property int notifyActMute: 1
        property int notifyActRemind: 2
    }

    CutegramDialog {
        id: newsletter
        telegram: telegramObject
        Component.onCompleted: {
            if(Cutegram.cutegramSubscribe)
                telegramObject.newsLetterDialog = newsletter
        }
    }

    Telegram {
        id: telegram
        defaultHostAddress: Cutegram.defaultHostAddress
        defaultHostDcId: Cutegram.defaultHostDcId
        defaultHostPort: Cutegram.defaultHostPort
        appId: Cutegram.appId
        appHash: Cutegram.appHash
        configPath: AsemanApp.homePath
        publicKeyFile: Devices.resourcePath + "/tg-server.pub"
        phoneNumber: accountItem.number
        autoCleanUpMessages: true
        onAuthCallRequested: acc_sign.callButton = false
        onAuthCodeRequested: {
            acc_sign.timeOut = sendCallTimeout
        }
        onAuthPasswordProtectedError: {
            Desktop.showMessage(View, qsTr("Password Error"), qsTr("Sorry. But Your account is an password protected account. We are working to add this feature to Cutegram as soon as possible.\nBut currently to fix this, disable 2 step verification, login using Cutegram and then enable 2 step verification again."))
            if( profiles.remove(phoneNumber) )
                Cutegram.logout(phoneNumber)
        }

        onAuthLoggedInChanged: {
            if( authLoggedIn && !view )
                view = account_view.createObject(acc_frame)
            else
            if( !authLoggedIn && view )
                view.destroy()
        }
        onIncomingMessage: {
            var dId = telegram.messageDialogId(msg.id)

            var window = view? view.windowOf(dId) : 0
            var windowIsActive = window? window.active && window.visible : false
            if( (view && isActive && acc_frame.visible) || windowIsActive ) {
                var cDialog = windowIsActive? window.currentDialog : view.currentDialog

                if( cDialog.peer.chatId && cDialog.peer.chatId == msg.toId.chatId ) {
                    telegramObject.messagesReadHistory(cDialog.peer.chatId)
                    return
                }
                if( cDialog.peer.userId && cDialog.peer.userId == msg.fromId ) {
                    telegramObject.messagesReadHistory(cDialog.peer.userId)
                    return
                }
            }

            var message = msg.message
            var myUser = telegram.user(telegram.me)

            if( telegram.userData.isMuted(dId) && (myUser.username=="" || message.indexOf("@"+myUser.username)==-1) )
                return
            if( msg.fromId == me || msg.out || !Cutegram.notification )
                return

            var user = telegram.user(msg.fromId)
            var dialog = telegram.dialog(dId)
            var title = user.firstName + " " + user.lastName
            title = title.trim()

            var chatObj
            if( dialog && dialog.peer.chatId != 0 )
                chatObj = telegramObject.chat(dialog.peer.chatId)

            if(chatObj)
                title = qsTr("Message on \"%1\" by \"%2\"").arg(chatObj.title).arg(title)

            var actions = new Array
            if(Desktop.desktopSession != 3) {
                actions[0] = notification.notifyActShow
                actions[1] = qsTr("Show")
                actions[2] = notification.notifyActMute
                actions[3] = qsTr("Mute")
            }

            if(Cutegram.messageAudio.length != 0) {
                sound_notify.source = ""
                sound_notify.source = Cutegram.messageAudio
                sound_notify.play()
            }

            if(msg.encrypted)
                message = qsTr("Message!")

            var location = chatObj? chatObj.photo.photoSmall.download.location : user.photo.photoSmall.download.location
            if(location && location.slice(0,Devices.localFilesPrePath.length) == Devices.localFilesPrePath)
                location = location.slice(Devices.localFilesPrePath.length, location.length)

            var nid = notification.sendNotify( title, message, location, 0, notifyTimeOut, actions )
            taskbarButton.userAttention()

            notifies_hash.insert(nid, msg)
        }
        onUserBecomeOnline: {
            var notifyValue = telegramObject.userData.notify(userId)
            var notifyOnline = notifyValue & UserData.NotifyOnline
            if(!notifyOnline)
                return
            if( !Cutegram.notification )
                return

            var window = view? view.windowOf(userId) : 0
            var windowIsActive = window? window.active && window.visible : false
            if( (view && isActive) || windowIsActive ) {
                var cDialog = windowIsActive? window.currentDialog : view.currentDialog

                if( cDialog.peer.userId && cDialog.peer.userId == userId ) {
                    telegramObject.messagesReadHistory(cDialog.peer.userId)
                    return
                }
            }

            var user = telegram.user(userId)
            var dialog = telegram.dialog(userId)
            var title = user.firstName + " " + user.lastName
            title = title.trim()

            var actions = new Array
            if(Desktop.desktopSession != 3) {
                actions[0] = notification.notifyActShow
                actions[1] = qsTr("Show")
            }

            var location = user.photo.photoSmall.download.location
            if(location && location.slice(0,Devices.localFilesPrePath.length) == Devices.localFilesPrePath)
                location = location.slice(Devices.localFilesPrePath.length, location.length)

            var message = qsTr("%1 is online").arg(title)

            var nid = notification.sendNotify( title, message, location, 0, notifyTimeOut, actions )
            notifies_hash.insert(nid, userId)
        }
        onUserStartTyping: {
            var notifyValue = telegramObject.userData.notify(userId)
            var notifyTyping = notifyValue & UserData.NotifyTyping
            if(!notifyTyping)
                return
            if( !Cutegram.notification )
                return

            var window = view? view.windowOf(userId) : 0
            var windowIsActive = window? window.active && window.visible : false
            if( (view && isActive) || windowIsActive ) {
                var cDialog = windowIsActive? window.currentDialog : view.currentDialog

                if( cDialog.peer.chatId && cDialog.peer.chatId == dId ) {
                    telegramObject.messagesReadHistory(cDialog.peer.chatId)
                    return
                }
                if( cDialog.peer.userId && cDialog.peer.userId == dId ) {
                    telegramObject.messagesReadHistory(cDialog.peer.userId)
                    return
                }
            }

            var user = telegram.user(userId)
            var dialog = telegram.dialog(dId)
            var title = user.firstName + " " + user.lastName
            title = title.trim()

            var chatObj
            if( dialog && dialog.peer.chatId != 0 )
                chatObj = telegramObject.chat(dialog.peer.chatId)

            var actions = new Array
            if(Desktop.desktopSession != 3) {
                actions[0] = notification.notifyActShow
                actions[1] = qsTr("Show")
            }

            var location = chatObj? chatObj.photo.photoSmall.download.location : user.photo.photoSmall.download.location
            if(location && location.slice(0,Devices.localFilesPrePath.length) == Devices.localFilesPrePath)
                location = location.slice(Devices.localFilesPrePath.length, location.length)

            var message
            if(chatObj)
                message = qsTr("%1 started typing on \"%2\"").arg(title).arg(chatObj.title)
            else
                message = qsTr("%1 started typing").arg(title)

            var nid = notification.sendNotify( title, message, location, 0, notifyTimeOut, actions )
            notifies_hash.insert(nid, dId)
        }
    }

    AccountSign {
        id: acc_sign
        anchors.fill: parent
        color: backColor0
        phoneRegistered: telegram.authPhoneRegistered
        visible: (telegram.authNeeded || telegram.authSignInError.length!=0 ||
                  telegram.authSignUpError.length != 0) && telegram.authPhoneChecked
        onSignInRequest: telegram.authSignIn(code)
        onSignUpRequest: telegram.authSignUp(code,fname,lname)
        onCallRequest: telegram.authSendCall()
    }

    AccountLoading {
        anchors.fill: parent
        z: 10
        active: (!telegram.authLoggedIn && !telegram.authNeeded &&
                telegram.authSignInError.length==0 && telegram.authSignUpError.length==0) ||
                !telegram.authPhoneChecked
    }

    Component {
        id: account_view
        AccountView {
            anchors.fill: parent
            telegramObject: telegram
            onAddParticianRequest: acc_frame.addParticianRequest()
        }
    }
}
