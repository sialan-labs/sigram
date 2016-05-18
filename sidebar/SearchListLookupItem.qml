import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Item {
    id: item
    height: 64*Devices.density
    width: parent.width

    property PeerDetails details: model.details

    signal loadRequest(variant peer)

    Row {
        id: row
        width: parent.width - 20*Devices.density
        anchors.centerIn: parent
        spacing: 6*Devices.density

        ToolKit.ProfileImage {
            id: avatar
            height: 42*Devices.density
            width: height
            anchors.verticalCenter: parent.verticalCenter
            engine: details.engine
            source: {
                if(details.chatFull)
                    return details.chatFull.chatPhoto
                else
                if(details.userFull)
                    return details.userFull.user
                else
                    return null
            }
        }

        Text {
            width: row.width - avatar.width - row.spacing
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 9*Devices.fontDensity
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            elide: Text.ElideRight
            maximumLineCount: 2
            color: "#333333"
            text: details.displayName
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: loadRequest(details.peer)
    }
}

