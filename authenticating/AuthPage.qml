import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

Rectangle {
    id: authenticating
    color: "#f7f7f7"

    property alias engine: auth.engine
    property bool started: false

    onStartedChanged: {
        if(started) {
            BackHandler.pushHandler(authenticating, function(){
                if(pageManager.index!=0)
                    return false
                started = false
                return true
            })
            pageManager.getItem(0).forceActiveFocus()
        } else {
            BackHandler.removeHandler(authenticating)
            startPage.forceActiveFocus()
        }
    }

    NullMouseArea { anchors.fill: parent }

    Telegram.Authenticate {
        id: auth
        onStateChanged: {
            console.debug(state)
            if(state == Telegram.Authenticate.AuthUnknown) {
                BackHandler.removeHandler(auth)
            } else
            if(lastState == Telegram.Authenticate.AuthUnknown) {
                BackHandler.pushHandler(auth, function(){
                    engine.phoneNumber = ""
                })
            }

            lastState = state
        }

        property int lastState: Telegram.Authenticate.AuthUnknown
    }

    PageManager {
        id: pageManager
        width: parent.width
        anchors.top: header.bottom
        anchors.bottom: footer.top
        components: [phone_component, wait_checking_component, signup_component,
            wait_signin_code_component, signin_component, password_component, wait_signin_component]
        Keys.onEscapePressed: { engine.phoneNumber = "" }
        index: {
            var res = 0
            switch(auth.state) {
            case Telegram.Authenticate.AuthUnknown:
                res = (engine.phoneNumber.length!=0? 1 : 0)
                break;
            case Telegram.Authenticate.AuthCheckingPhoneError:
            case Telegram.Authenticate.AuthCodeRequestingError:
                res = 0
                getItem(0).error = "Error %1: %2".arg(auth.errorCode).arg(auth.errorText)
                break
            case Telegram.Authenticate.AuthCheckingPhone:
                res = 1
                break
            case Telegram.Authenticate.AuthSignUpNeeded:
                res = 2
                break
            case Telegram.Authenticate.AuthCodeRequesting:
                res = 3
                break
            case Telegram.Authenticate.AuthLoggingInError:
                console.debug(getItem(4))
                getItem(4).error = "Error %1: %2".arg(auth.errorCode).arg(auth.errorText)
            case Telegram.Authenticate.AuthCodeRequested:
                res = 4
                break
            case Telegram.Authenticate.AuthPasswordRequested:
                res = 5
                break
            case Telegram.Authenticate.AuthLoggingIn:
                res = 6
                break
            case Telegram.Authenticate.AuthLoggedIn:
                res = 7
                break
            }
            return res
        }
    }

    StartPage {
        id: startPage
        anchors.fill: parent
        opacity: started? 0 : 1
        innerScale: opacity*0.3 + 0.7
        visible: opacity != 0
        onStartRequest: started = true

        Behavior on opacity {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 300}
        }

        Component.onCompleted: forceActiveFocus()
    }

    Rectangle {
        id: header
        y: started? 0 : -height
        width: parent.width
        height: 50*Devices.density
        color: CutegramGlobals.baseColor
        visible: started

        Behavior on y {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 300}
        }

        Text {
            anchors.centerIn: parent
            text: qsTr("Authenticating")
            color: "#ffffff"
            font.pixelSize: 12*Devices.fontDensity
        }
    }

    Rectangle {
        id: footer
        y: started? parent.height-height : parent.height
        width: parent.width
        height: 50*Devices.density
        color: CutegramGlobals.baseColor
        visible: started

        Behavior on y {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 300}
        }
    }

    Component {
        id: phone_component
        PhoneSection {
            onPhoneAccepted: {
                engine.phoneNumber = ""
                engine.phoneNumber = phoneNumber
            }
        }
    }

    Component {
        id: signup_component
        SignUpPage {
            onSignUpRequest: auth.signUp(firstName, lastName)
            Component.onCompleted: phoneNumber = engine.phoneNumber
        }
    }

    Component {
        id: signin_component
        SignInPage {
            remainingTime: auth.remainingTime
            onCodeAccepted: auth.signIn(code)
        }
    }

    Component {
        id: password_component
        AuthPassword {
            onPasswordAccepted: auth.checkPassword(password)
        }
    }

    Component {
        id: wait_checking_component
        WaitPage {
            enabled: (pageManager.components.indexOf(wait_checking_component) == pageManager.index)
            text: qsTr("Checking your phone number...")
        }
    }

    Component {
        id: wait_signin_code_component
        WaitPage {
            enabled: (pageManager.components.indexOf(wait_signin_code_component) == pageManager.index)
            text: qsTr("Requesting sign-in code...")
        }
    }

    Component {
        id: wait_signin_component
        WaitPage {
            enabled: (pageManager.components.indexOf(wait_signin_component) == pageManager.index)
            text: qsTr("Signing in...")
        }
    }
}

