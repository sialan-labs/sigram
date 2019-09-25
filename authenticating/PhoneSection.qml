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

    signal phoneAccepted(string phoneNumber)

    Behavior on opacity {
        NumberAnimation {easing.type: Easing.OutCubic; duration: 400}
    }

    Rectangle {
        height: parent.height
        anchors.right: parent.right
        color: "#dddddd"
        width: {
            var res = loginBox.x - 30*Devices.density
            if(res > body.width/3)
                res = body.width/3
            return res
        }

        CountryList {
            id: country_list
            anchors.fill: parent
        }
    }

    Text {
        anchors.bottom: loginBox.top
        anchors.bottomMargin: 40*Devices.density
        anchors.left: loginBox.left
        anchors.right: loginBox.right
        horizontalAlignment: Text.AlignHCenter
        color: "#555555"
        font.pixelSize: 12*Devices.fontDensity
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: qsTr("First, Enter your phone number to verifying your account.")
    }

    Column {
        id: loginBox
        anchors.centerIn: parent
        width: 230*Devices.density
        spacing: 7*Devices.density

        Rectangle {
            width: parent.width
            height: 35*Devices.density
            radius: 5*Devices.density
            color: "#dddddd"

            Text {
                id: country_code
                anchors.verticalCenter: parent.verticalCenter
                x: y
                font.pixelSize: 12*Devices.fontDensity
                color: "#333333"
                text: "+" + country_list.currentCode
            }

            Rectangle {
                id: country_separator
                anchors.left: country_code.right
                anchors.leftMargin: 8*Devices.density
                height: parent.height
                width: 1*Devices.density
                color: "#cccccc"
            }

            TextInput {
                id: phone_txt
                anchors.left: country_separator.right
                anchors.leftMargin: 8*Devices.density
                anchors.right: parent.right
                height: parent.height
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: 12*Devices.fontDensity
                color: "#333333"
                selectByMouse: true
                selectionColor: CutegramGlobals.baseColor
                selectedTextColor: "#ffffff"
                validator: RegExpValidator{ regExp: /\d*/ }
                Keys.onTabPressed: send_btn.forceActiveFocus()
                Keys.onEscapePressed: BackHandler.back()
                onAccepted: send_btn.clicked()

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#aaaaaa"
                    visible: parent.text.length == 0
                    text: qsTr("Phone Number")
                }

                CursorShapeArea {
                    cursorShape: Qt.IBeamCursor
                    anchors.fill: parent
                }
            }
        }

        Button {
            id: send_btn
            width: parent.width
            height: 35*Devices.density
            radius: 5*Devices.density
            normalColor: CutegramGlobals.baseColor
            highlightColor: Qt.darker(normalColor, 1.1)
            textColor: "#ffffff"
            text: qsTr("Send")
            textFont.bold: false
            textFont.pixelSize: 10*Devices.fontDensity
            Keys.onTabPressed: phone_txt.forceActiveFocus()
            Keys.onEscapePressed: BackHandler.back()
            onClicked: {
                error = ""
                var phoneNumber = country_code.text + phone_txt.text
                phoneAccepted(phoneNumber)
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
        phone_txt.forceActiveFocus()
    }
}

