import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0

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
        anchors.bottom: column.top
        anchors.left: column.left
        anchors.bottomMargin: 4*physicalPlatformScale
        font.family: SApp.globalFontFamily
        font.pixelSize: 10*fontsScale
        color: "#ffffff"
        visible: time_out_timer.running
        text: Math.floor(time_out_timer.countDown/60).toString() + ":" + time_out_timer.countDown%60
    }

    Column {
        id: column
        width: 300*physicalPlatformScale
        anchors.centerIn: parent
        spacing: 4*physicalPlatformScale

        LineEdit {
            id: code_txt
            width: column.width
            anchors.horizontalCenter: parent.horizontalCenter
            placeholder: qsTr("Code")
            textColor: "#ffffff"
            placeholderColor: "#888888"
            color: "#111111"
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
            textColor: "#ffffff"
            placeholderColor: "#888888"
            color: "#111111"
            validator: RegExpValidator{regExp: /\d*/}
            visible: !phoneRegistered
            pickerEnable: Devices.isTouchDevice
            onAccepted: lname_text.focus = true
        }

        LineEdit {
            id: lname_text
            width: column.width
            anchors.horizontalCenter: parent.horizontalCenter
            placeholder: qsTr("Last Name")
            textColor: "#ffffff"
            placeholderColor: "#888888"
            color: "#111111"
            validator: RegExpValidator{regExp: /\d*/}
            visible: !phoneRegistered
            pickerEnable: Devices.isTouchDevice
            onAccepted: accept()
        }

        Button {
            width: column.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: 40*physicalPlatformScale
            normalColor: "#339DCC"
            highlightColor: "#3384CC"
            textColor: "#ffffff"
            text: phoneRegistered? qsTr("Sign In") : qsTr("Sign Up")
            onClicked: accept()
        }
    }

    Text {
        id: call_btn
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10*physicalPlatformScale
        font.family: SApp.globalFontFamily
        font.underline: true
        font.pixelSize: 10*fontsScale
        color: callButton? "#ffffff" : "#aaaaaa"
        text: callButton? qsTr("Call Request") : qsTr("Requested")
        visible: false

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            anchors.margins: -10*physicalPlatformScale
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
