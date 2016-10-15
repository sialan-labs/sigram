import QtQuick 2.4
import AsemanTools 1.0
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

Item {
    id: addBtn
    width: column.width
    height: column.height

    property alias icon: iconTxt.text
    property alias text: txt.text

    signal clicked()

    Column {
        id: column
        anchors.centerIn: parent
        spacing: 20*Devices.density

        Text {
            id: iconTxt
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: Awesome.family
            font.pixelSize: 90*Devices.fontDensity
            text: Awesome.fa_user_secret
            color:txt.color
        }

        Text {
            id: txt
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 13*Devices.fontDensity
            text: qsTr("New Secret Chat")
            color: marea.containsMouse? CutegramSettings.masterColor : "#444444"
        }
    }

    MouseArea {
        id: marea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: addBtn.clicked()
    }
}
