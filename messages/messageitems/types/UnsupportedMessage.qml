import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../../../thirdparty"
import "../../../globals"

AbstractMessage {
    id: msgItem
    width: 180*Devices.density
    height: 100*Devices.density

    Text {
        width: parent.width - msgItem.margins
        anchors.centerIn: parent
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.pixelSize: 10*Devices.fontDensity
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#333333"
        text: qsTr("Unsupported Message")
    }

}

