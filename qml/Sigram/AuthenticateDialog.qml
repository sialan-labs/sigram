import QtQuick 2.0
import SialanTools 1.0

Rectangle {
    id: auth_dialog
    color: backColor0
    focus: true

    signal accepted( string number )

    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: View.statusBarHeight + 50*physicalPlatformScale
        color: backColor1

        Text {
            anchors.fill: parent
            anchors.margins: 12*physicalPlatformScale
            verticalAlignment: Text.AlignVCenter
            font.family: SApp.globalFontFamily
            font.pixelSize: 13*fontsScale
            text: qsTr("Authenticating")
            color: textColor0
        }
    }

    Item {
        id: frame
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: footer.top
        clip: true

        property bool minimumWidth: width*0.4<columnWidth
        property real columnWidth: 300*physicalPlatformScale

        CountriesPhoneList {
            id: cphones_list
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: frame.minimumWidth? frame.width : parent.width/2 - column.width/2 - 20*physicalPlatformScale
            visible: cphones_list.number.length==0 || !frame.minimumWidth

            onNumberChanged: {
                if( number.length != 0 )
                    BackHandler.pushHandler(cphones_list,cphones_list.back)
                else
                    BackHandler.removeHandler(cphones_list)
            }

            function back() {
                number = ""
            }
        }

        Text {
            id: country_code
            x: column.x + phone_number.x
            anchors.bottom: column.top
            anchors.margins: 8*physicalPlatformScale
            font.family: SApp.globalFontFamily
            font.pixelSize: 15*fontsScale
            color: textColor0
            text: "+" + cphones_list.number
            visible: column.visible
        }

        Column {
            id: column
            anchors.centerIn: parent
            spacing: 4*physicalPlatformScale
            visible: cphones_list.number.length!=0 || !frame.minimumWidth

            LineEdit {
                id: phone_number
                width: frame.columnWidth
                anchors.horizontalCenter: parent.horizontalCenter
                placeholder: qsTr("Phone Number")
                textColor: textColor0
                placeholderColor: "#888888"
                color: backColor0
                validator: RegExpValidator{regExp: /(?!0)\d*/}
                pickerEnable: Devices.isTouchDevice
                onAccepted: auth_dialog.accepted( country_code.text + text )
            }

            Button {
                width: frame.columnWidth
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40*physicalPlatformScale
                normalColor: "#339DCC"
                highlightColor: "#3384CC"
                textColor: textColor0
                text: qsTr("Login")
                onClicked: phone_number.accepted()
            }
        }
    }

    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: View.navigationBarHeight + 50*physicalPlatformScale
        color: backColor1
    }
}
