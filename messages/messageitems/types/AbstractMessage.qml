import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0

Item {
    property real maximumWidth
    property real maximumHeight
    property real margins: 10*Devices.density

    property int messageType: Enums.TypeUnsupportedMessage

    property Engine engine
    property Message message
    property User user
    readonly property MessageMedia media: message? message.media : null

    property bool downloadable
    property bool uploading
    property bool downloading
    property bool transfaring
    property real transfared
    property real transfaredSize
    property real totalSize
    property string filePath
    property string thumbPath

    signal clickRequest()
    signal copyRequest()
}
