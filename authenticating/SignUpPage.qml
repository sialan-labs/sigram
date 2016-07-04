import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

Item {
    id: body

    property alias error: error_txt.text
    property alias phoneNumber: phone_txt.text

    signal signUpRequest(string firstName, string lastName)

    Text {
        anchors.bottom: loginBox.top
        anchors.bottomMargin: 40*Devices.density
        anchors.left: loginBox.left
        anchors.right: loginBox.right
        horizontalAlignment: Text.AlignHCenter
        color: "#555555"
        font.pixelSize: 12*Devices.fontDensity
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: qsTr("Ok, You have not an account on this phone number. So you need to sign up.")
    }

    Column {
        id: loginBox
        anchors.centerIn: parent
        width: 230*Devices.density
        spacing: 7*Devices.density

        Text {
            id: phone_txt
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 12*Devices.fontDensity
            color: "#555555"
            text: "+98123456789"
        }

        Rectangle {
            width: parent.width
            height: 35*Devices.density
            radius: 5*Devices.density
            color: "#dddddd"

            TextInput {
                id: firstname_txt
                anchors.left: parent.left
                anchors.leftMargin: 8*Devices.density
                anchors.right: parent.right
                height: parent.height
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: 10*Devices.fontDensity
                color: "#333333"
                selectByMouse: true
                selectionColor: CutegramGlobals.baseColor
                selectedTextColor: "#ffffff"
                Keys.onTabPressed: lastname_txt.forceActiveFocus()
                Keys.onEscapePressed: BackHandler.back()
                onAccepted: signup_btn.clicked()

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#aaaaaa"
                    visible: parent.text.length == 0
                    text: qsTr("First Name")
                }

                CursorShapeArea {
                    cursorShape: Qt.IBeamCursor
                    anchors.fill: parent
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 35*Devices.density
            radius: 5*Devices.density
            color: "#dddddd"

            TextInput {
                id: lastname_txt
                anchors.left: parent.left
                anchors.leftMargin: 8*Devices.density
                anchors.right: parent.right
                height: parent.height
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: 10*Devices.fontDensity
                color: "#333333"
                selectByMouse: true
                selectionColor: CutegramGlobals.baseColor
                selectedTextColor: "#ffffff"
                Keys.onTabPressed: signup_btn.forceActiveFocus()
                Keys.onEscapePressed: BackHandler.back()
                onAccepted: signup_btn.clicked()

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#aaaaaa"
                    visible: parent.text.length == 0
                    text: qsTr("Last Name")
                }

                CursorShapeArea {
                    cursorShape: Qt.IBeamCursor
                    anchors.fill: parent
                }
            }
        }

        Button {
            id: signup_btn
            width: parent.width
            height: 35*Devices.density
            radius: 5*Devices.density
            normalColor: CutegramGlobals.baseColor
            highlightColor: Qt.darker(normalColor, 1.1)
            textColor: "#ffffff"
            text: qsTr("Sign Up")
            textFont.bold: false
            textFont.pixelSize: 10*Devices.fontDensity
            Keys.onTabPressed: firstname_txt.forceActiveFocus()
            Keys.onEscapePressed: BackHandler.back()
            onClicked: {
                error = ""
                var firstName = firstname_txt.text.trim()
                var lastName = lastname_txt.text.trim()
                if(firstName.length == 0 || lastName.length == 0) {
                    error = "Firstname or Lastname field is empty."
                    return
                }

                signUpRequest(firstname_txt.text, lastname_txt.text)
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
        firstname_txt.forceActiveFocus()
    }
}

