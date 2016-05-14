import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Item {
    height: typing_text.height + 32*Devices.density
    width: typing_text.width + 32*Devices.density

    property variant typingUsers

    DropShadow {
        source: typing_frame
        anchors.fill: source
        horizontalOffset: 1
        spread: 0.9
        verticalOffset: 1
        radius: 32.0
        samples: 32
        color: "#ffffff"
    }

    Item {
        id: typing_frame
        anchors.fill: parent

        Text {
            id: typing_text
            anchors.centerIn: parent
            font.pixelSize: 9*Devices.fontDensity
            color: "#333333"
            text: {
                var result = ""
                if(typingUsers.length == 0)
                    return result

                var list = typingUsers
                for(var i=0; i<list.length; i++) {
                    var user = list[i]
                    var name = (user.firstName + " " + user.lastName).trim()

                    if(result.length != 0)
                        result += ", "
                    result += name
                }

                return qsTr("%1 typing...").arg(result)
            }
        }
    }
}

