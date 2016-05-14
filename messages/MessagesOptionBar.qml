import QtQuick 2.0
import AsemanTools 1.0
import "../globals"
import "../awesome"

Item {
    id: optionBar
    height: 34*Devices.density

    property int selectedCount

    signal forwardRequest()
    signal deleteRequest()
    signal clearRequest()

    NullMouseArea {
        anchors.fill: parent
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        x: countTxt.y

        Text {
            id: countTxt
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 9*Devices.fontDensity
            color: CutegramGlobals.titleBarTextsColor
            opacity: 0.7
            text: qsTr("%1 messages").arg(selectedCount)
        }

        Item {
            width: 8*Devices.density
            height: 1
        }

        Button {
            anchors.verticalCenter: parent.verticalCenter
            height: optionBar.height
            width: height
            normalColor: "#00000000"
            highlightColor: "#88e6e6e6"
            hoverColor: "#88f0f0f0"
            opacity: 0.6
            textFont.family: Awesome.family
            textFont.pixelSize: 11*Devices.fontDensity
            textColor: CutegramGlobals.titleBarTextsColor
            text: Awesome.fa_mail_forward
            onClicked: forwardRequest()
        }

        Button {
            anchors.verticalCenter: parent.verticalCenter
            height: optionBar.height
            width: height
            normalColor: "#00000000"
            highlightColor: "#88e6e6e6"
            hoverColor: "#88f0f0f0"
            opacity: 0.6
            textFont.family: Awesome.family
            textFont.pixelSize: 11*Devices.fontDensity
            textColor: CutegramGlobals.titleBarTextsColor
            text: Awesome.fa_trash
            onClicked: deleteRequest()
        }
    }

    Button {
        anchors.verticalCenter: parent.verticalCenter
        x: parent.width - width - countTxt.y
        height: optionBar.height
        width: height
        normalColor: "#00000000"
        highlightColor: "#88e6e6e6"
        hoverColor: "#88f0f0f0"
        textFont.family: Awesome.family
        textFont.pixelSize: 11*Devices.fontDensity
        textColor: "#db2424"
        text: Awesome.fa_remove
        onClicked: clearRequest()
    }
}

