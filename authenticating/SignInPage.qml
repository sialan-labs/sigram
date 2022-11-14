import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

Item {
    id: body

    property alias error: error_txt.text
    property int remainingTime

    signal codeAccepted(string code)

    Text {
        anchors.bottom: loginBox.top
        anchors.bottomMargin: 40*Devices.density
        anchors.left: loginBox.left
        anchors.right: loginBox.right
        horizontalAlignment: Text.AlignHCenter
        color: "#555555"
        font.pixelSize: 12*Devices.fontDensity
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: qsTr("Then enter the code sent to your phone number and sign in.")
    }

    Column {
        id: loginBox
        anchors.centerIn: parent
        width: 230*Devices.density
        spacing: 7*Devices.density

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 80*Devices.fontDensity
            color: "#555555"
            text: {
                var mins = (Math.floor(remainingTime/60)).toString()
                while(mins.length < 2)
                    mins = "0" + mins

                var secs = (remainingTime%60).toString()
                while(secs.length < 2)
                    secs = "0" + secs

                return mins + ":" + secs
            }
        }

        Rectangle {
            width: parent.width
            height: 35*Devices.density
            radius: 5*Devices.density
            color: "#dddddd"

            TextInput {
                id: code_txt
                anchors.left: parent.left
                anchors.leftMargin: 8*Devices.density
                anchors.right: parent.right
                height: parent.height
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                font.pixelSize: 12*Devices.fontDensity
                color: "#333333"
                selectByMouse: true
                selectionColor: CutegramGlobals.baseColor
                selectedTextColor: "#ffffff"
                validator: RegExpValidator{ regExp: /\d*/ }
                Keys.onTabPressed: signin_btn.forceActiveFocus()
                Keys.onEscapePressed: BackHandler.back()
                onAccepted: signin_btn.clicked()

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#aaaaaa"
                    visible: parent.text.length == 0
                    text: qsTr("Code")
                }

                CursorShapeArea {
                    cursorShape: Qt.IBeamCursor
                    anchors.fill: parent
                }
            }
        }

        Button {
            id: signin_btn
            width: parent.width
            height: 35*Devices.density
            radius: 5*Devices.density
            normalColor: CutegramGlobals.baseColor
            highlightColor: Qt.darker(normalColor, 1.1)
            textColor: "#ffffff"
            text: qsTr("Sign In")
            textFont.bold: false
            textFont.pixelSize: 10*Devices.fontDensity
            Keys.onTabPressed: code_txt.forceActiveFocus()
            Keys.onEscapePressed: BackHandler.back()
            onClicked: {
                error = ""
                codeAccepted(code_txt.text)
            }
        }
    }

    Text {
        id: error_txt
        anchors.top: loginBox.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20*Devices.density
        color: "#db2424"
        font.pixelSize: 9*Devices.fontDensity
    }

    function forceActiveFocus() {
        code_txt.forceActiveFocus()
    }
}

