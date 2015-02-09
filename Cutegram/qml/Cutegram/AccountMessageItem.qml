import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

Item {
    id: msg_item
    width: 100
    height: logicalHeight<minimumHeight? minimumHeight : logicalHeight
    clip: true

    property real messageFrameX: back_rect.x
    property real messageFrameY: back_rect.y
    property real messageFrameWidth: back_rect.width
    property real messageFrameHeight: back_rect.height

    property real logicalHeight: action_item.hasAction? action_item.height: column.height + frameMargins*2 + textMargins*2
    property real minimumHeight: 48*Devices.density
    property real maximumWidth: 2*width/3

    property alias maximumMediaHeight: msg_media.maximumMediaHeight
    property alias maximumMediaWidth: msg_media.maximumMediaWidth

    property bool visibleNames: true

    property Message message
    property User user: telegramObject.user(message.fromId)
    property User fwdUser: telegramObject.user(message.fwdFromId)

    property real minimumWidth: 100*Devices.density
    property real textMargins: 4*Devices.density
    property real frameMargins: 4*Devices.density

    property bool sent: message.sent
    property bool uploading: message.upload.fileId != 0

    property alias hasMedia: msg_media.hasMedia
    property bool encryptMedia: message.message.length==0 && message.encrypted
    property alias mediaLOcation: msg_media.locationObj

    property alias selectedText: msg_txt.selectedText

    property bool modernMode: false

    signal dialogRequest(variant dialogObject)

    onSentChanged: {
        if( sent )
            indicator.stop()
        else
            indicator.start()
    }

    AccountMessageAction {
        id: action_item
        anchors.left: parent.left
        anchors.right: parent.right
        message: msg_item.message
    }

    Row {
        id: frame_row
        anchors.fill: parent
        layoutDirection: message.out? Qt.RightToLeft : Qt.LeftToRight
        visible: !action_item.hasAction
        spacing: frameMargins

        ContactImage {
            id: img
            anchors.verticalCenter: parent.verticalCenter
            width: 40*Devices.density
            height: width
            user: msg_item.user
            isChat: false

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: msg_item.dialogRequest( telegramObject.fakeDialogObject(img.user.id, false) )
            }
        }

        ContactImage {
            id: forward_img
            anchors.verticalCenter: parent.verticalCenter
            width: img.width
            height: img.height
            visible: message.fwdFromId != 0
            user: msg_item.fwdUser
            isChat: false

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: msg_item.dialogRequest( telegramObject.fakeDialogObject(forward_img.user.id, false) )
            }
        }

        Item {
            id: spacer
            height: 10
            visible: modernMode
            width: parent.width/2 - (forward_img.width+frameMargins)*forward_img.visible
                   - (img.width+frameMargins) - back_rect.width/2
        }

        Rectangle {
            id: back_rect
            width: column.width + 2*textMargins
            height: column.height + 2*textMargins
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            radius: 3*Devices.density

            Rectangle {
                anchors.fill: parent
                opacity: hasMedia || encryptMedia? 1 : 0.3
                radius: parent.radius
                color: {
                    if(hasMedia || encryptMedia)
                        return "#111111"
                    else
                    if(message.out)
                        return Cutegram.highlightColor
                    else
                        return "#ffffff"
                }
            }

            Column {
                id: column
                anchors.centerIn: parent
                height: (visibleNames?user_name.height:0) + (uploading?uploadItem.height:0) + (msg_media.hasMedia?msg_media.height:0) + spacing + msg_column.height
                clip: true

                Text {
                    id: user_name
                    font.pixelSize: 11*Devices.fontDensity
                    font.family: AsemanApp.globalFont.family
                    lineHeight: 1.3
                    color: Cutegram.highlightColor
                    text: user.firstName + " " + user.lastName
                    visible: visibleNames
                }

                AccountMessageUpload {
                    id: uploadItem
                    telegram: telegramObject
                    message: msg_item.message
                }

                AccountMessageMedia {
                    id: msg_media
                    media: message.media
                    visible: msg_media.hasMedia && !uploading
                }

                Column {
                    id: msg_column
                    anchors.right: parent.right

                    Item {
                        id: msg_txt_frame
                        width: msg_txt.width + 8*Devices.density
                        height: msg_txt.height + 8*Devices.density
                        visible: !msg_media.hasMedia && !uploading

                        TextEdit {
                            id: msg_txt
                            width: htmlWidth>maximumWidth? maximumWidth : htmlWidth
                            anchors.centerIn: parent
                            font.pixelSize: Cutegram.font.pointSize*Devices.fontDensity
                            font.family: Cutegram.font.family
                            persistentSelection: true
                            activeFocusOnPress: false
                            selectByMouse: true
                            readOnly: true
                            selectionColor: masterPalette.highlight
                            selectedTextColor: masterPalette.highlightedText
                            color: encryptMedia? "#ffffff" : textColor0
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: emojis.bodyTextToEmojiText(messageText)
                            textFormat: Text.RichText
                            height: contentHeight
                            onLinkActivated: Qt.openUrlExternally(link)

                            property real htmlWidth: Cutegram.htmlWidth(text)
                            property string messageText: encryptMedia? qsTr("Media files is not supported on secret chat currently") : message.message
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        spacing: 4*Devices.density

                        Text {
                            id: time_txt
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: 9*Devices.fontDensity
                            color: textColor2
                            text: Cutegram.getTimeString(msgDate)
                            verticalAlignment: Text.AlignVCenter

                            property variant msgDate: CalendarConv.fromTime_t(message.date)
                        }

                        Item {
                            id: state_indict
                            width: 12*Devices.density
                            height: 8*Devices.density
                            visible: message.out
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: seen_indict
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                width: 8*Devices.density
                                height: width
                                visible: !message.unread && message.out
                                source: hasMedia || encryptMedia? "files/sent-light.png" : "files/sent.png"
                                sourceSize: Qt.size(width,height)
                            }

                            Image {
                                id: sent_indict
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                width: 8*Devices.density
                                height: width
                                visible: message.sent && message.out
                                source: hasMedia || encryptMedia? "files/sent-light.png" : "files/sent.png"
                                sourceSize: Qt.size(width,height)
                            }

                            Indicator {
                                id: indicator
                                anchors.centerIn: parent
                                light: false
                                modern: true
                                indicatorSize: 10*Devices.density
                                Component.onCompleted: if(!sent) start()
                            }
                        }
                    }
                }
            }
        }
    }

    function click() {
        msg_media.click()
    }

    function copy() {
        if(hasMedia)
            Devices.clipboardUrl = [msg_media.locationObj.download.location]
        else
        if(msg_txt.selectedText.length == 0)
            Devices.clipboard = message.message
        else
            msg_txt.copy()
    }

    function discardSelection() {
        msg_txt.deselect()
    }
}
