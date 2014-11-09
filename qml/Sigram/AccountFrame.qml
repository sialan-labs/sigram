import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0

Rectangle {
    id: acc_frame
    width: 100
    height: 62
    color: "#333333"

    property ProfilesModelItem accountItem

    QtObject {
        id: privates
    }

    Telegram {
        id: telegram
        configPath: SApp.homePath
        publicKeyFile: Devices.resourcePath + "/tg-server.pub"
        phoneNumber: accountItem.number
        onAuthCallRequested: acc_sign.callButton = false
        onAuthCodeRequested: acc_sign.timeOut = sendCallTimeout
    }

    AccountSign {
        id: acc_sign
        anchors.fill: parent
        color: "#333333"
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
}
