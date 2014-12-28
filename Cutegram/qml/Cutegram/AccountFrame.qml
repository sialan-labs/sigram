import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0

Rectangle {
    id: acc_frame
    width: 100
    height: 62
    color: "#333333"

    property ProfilesModelItem accountItem
    property AccountView view
    property alias telegramObject: telegram
    property alias unreadCount: telegram.unreadCount

    property bool isActive: View.active && View.visible

    onIsActiveChanged: {
        telegram.online = isActive
    }

    QtObject {
        id: privates
    }

    HashObject {
        id: notifies_hash
    }

    Notification {
        id: notification
        onNotifyClosed: notifies_hash.remove(id)
        onNotifyAction: {
            var msg = notifies_hash.value(id)
            if( action == notifyActShow ) {
                if( view )
                    view.currentDialog = telegram.messageDialog(msg.id)

                Cutegram.active()
            } else
            if( action == notifyActMute ) {
                if( !view )
                    return

                var dId = telegram.messageDialogId(msg.id)
                telegram.userData.addMute(dId)
            }
        }

        property int notifyActShow: 0
        property int notifyActMute: 1
        property int notifyActRemind: 2
    }

    Telegram {
        id: telegram
        configPath: AsemanApp.homePath
        publicKeyFile: Devices.resourcePath + "/tg-server.pub"
        phoneNumber: accountItem.number
        onAuthCallRequested: acc_sign.callButton = false
        onAuthCodeRequested: {
            acc_sign.timeOut = sendCallTimeout
        }
        onAuthLoggedInChanged: {
            if( authLoggedIn && !view )
                view = account_view.createObject(acc_frame)
            else
            if( !authLoggedIn && view )
                view.destroy()
        }
        onIncomingMessage: {
            if( view && isActive ) {
                if( view.currentDialog.peer.chatId && view.currentDialog.peer.chatId == msg.toId.chatId )
                    return
                if( view.currentDialog.peer.userId && view.currentDialog.peer.userId == msg.fromId )
                    return
            }

            var dId = telegram.messageDialogId(msg.id)
            if( telegram.userData.isMuted(dId) )
                return
            if( !Cutegram.notification )
                return

            var user = telegram.user(msg.fromId)
            var title = user.firstName + " " + user.lastName

            var actions = new Array
            if(Desktop.desktopSession != Desktop.Unity) {
                actions[0] = notification.notifyActShow
                actions[1] = qsTr("Show")
                actions[2] = notification.notifyActMute
                actions[3] = qsTr("Mute")
            }

            var nid = notification.sendNotify( title, msg.message, user.photo.photoSmall.download.location, 0, 3000, actions )

            notifies_hash.insert(nid, msg)
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
        }
    }
}
