import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0

Rectangle {
    id: auth_sign
    width: 100
    height: 62

    signal signInRequest( string code )
    signal signUpRequest( string code, string fname, string lname )
    signal callRequest()

    property bool phoneRegistered: true
    property bool callButton: true
    property int timeOut: 0

    onTimeOutChanged: {
        time_out_timer.countDown = timeOut
        time_out_timer.restart()
    }

    Timer {
        id: time_out_timer
        interval: 1000
        repeat: true
        onTriggered: {
            if( countDown == 0 ) {
                callButton = true
                call_btn.visible = true
                stop()
                return
            }

            countDown--
        }

        property int countDown: 0
    }

    Text {
        id: timeout_text
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: column.top
        anchors.bottomMargin: 4*Devices.density
        font.family: AsemanApp.globalFont.family
        font.pixelSize: Math.floor(18*Devices.fontDensity)
        color: textColor0
        visible: time_out_timer.running
        text: {
            var second = time_out_timer.countDown%60
            var minute = Math.floor(time_out_timer.countDown/60)
            return (minute<10? "0"+minute : minute) + ":" + (second<10? "0"+second : second)
        }
    }

    Column {
        id: column
        width: 300*Devices.density
        anchors.centerIn: parent
        spacing: 4*Devices.density

        LineEdit {
            id: code_txt
            width: column.width
            anchors.horizontalCenter: parent.horizontalCenter
            placeholder: qsTr("Code")
            textColor: textColor0
            placeholderColor: "#888888"
            color: backColor1
            validator: RegExpValidator{regExp: /\d*/}
            pickerEnable: Devices.isTouchDevice
            onAccepted: {
                if( phoneRegistered )
                    accept()
                else
                    fname_text.focus = true
            }
        }

        LineEdit {
            id: fname_text
            width: column.width
            anchors.horizontalCenter: parent.horizontalCenter
            placeholder: qsTr("First Name")
            textColor: textColor0
            placeholderColor: "#888888"
            color: backColor1
            visible: !phoneRegistered
            pickerEnable: Devices.isTouchDevice
            onAccepted: lname_text.focus = true
        }

        LineEdit {
            id: lname_text
            width: column.width
            anchors.horizontalCenter: parent.horizontalCenter
            placeholder: qsTr("Last Name")
            textColor: textColor0
            placeholderColor: "#888888"
            color: backColor1
            visible: !phoneRegistered
            pickerEnable: Devices.isTouchDevice
            onAccepted: accept()
        }

        Button {
            width: column.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: 40*Devices.density
            normalColor: "#339DCC"
            highlightColor: "#3384CC"
            textColor: textColor0
            text: {
                if(time_out_timer.running)
                    return phoneRegistered? qsTr("Sign In") : qsTr("Sign Up")
                else
                    return qsTr("Resend Code")
            }
            onClicked: {
                if(time_out_timer.running)
                    accept()
                else
                    telegramObject.authSendCode()
            }
        }
    }

    Text {
        id: call_btn
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10*Devices.density
        font.family: AsemanApp.globalFont.family
        font.underline: true
        font.pixelSize: Math.floor(10*Devices.fontDensity)
        color: callButton? textColor0 : "#aaaaaa"
        text: callButton? qsTr("Call Request") : qsTr("Requested")
        visible: false

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            anchors.margins: -10*Devices.density
            onClicked: if(callButton) auth_sign.callRequest()
        }
    }

    function accept() {
        if( code_txt.text.length < 4 )
            return
        if( !phoneRegistered && fname_text.text.length == 0 )
            return
        if( !phoneRegistered && lname_text.text.length == 0 )
            return

        if( phoneRegistered )
            signInRequest(code_txt.text)
        else
            signUpRequest(code_txt.text, fname_text.text, lname_text.text)
    }
}
