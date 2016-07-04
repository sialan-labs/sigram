import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import TelegramQml 2.0
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"
import "../toolkit" as ToolKit

ToolKit.AccountHomeItem {
    id: dialog
    color: "#fefefe"

    property Engine engine
    property InputPeer currentPeer

    readonly property bool refreshing: item? item.refreshing : false

    signal peerSelected(variant peer)
    signal forwardRequest(variant inputPeer, variant msgIds)

    delegate: Item {
        anchors.fill: parent

        NullMouseArea { anchors.fill: parent }

        property alias refreshing: mdlist.refreshing

        Column {
            anchors.fill: parent

            Item {
                id: header
                width: parent.width
                height: 32*Devices.density
                z: typeCombo.z

                ToolKit.ComboBox {
                    id: typeCombo
                    anchors.left: parent.left
                    anchors.leftMargin: 10*Devices.density
                    anchors.verticalCenter: parent.verticalCenter
                    width: 130*Devices.density
                    modelArray: [
                        {"name":qsTr("Medias")   , "icon": Awesome.fa_play_circle_o},
                        {"name":qsTr("Photos")   , "icon": Awesome.fa_photo},
                        {"name":qsTr("Videos")   , "icon": Awesome.fa_video_camera},
                        {"name":qsTr("Documents"), "icon": Awesome.fa_file_o},
                        {"name":qsTr("Musics")   , "icon": Awesome.fa_music},
                        {"name":qsTr("Gifs")     , "icon": Awesome.fa_video_camera},
                        {"name":qsTr("Links")    , "icon": Awesome.fa_link},
                        {"name":qsTr("Voices")   , "icon": Awesome.fa_microphone}
                    ]
                }
            }

            Item {
                id: listArea
                width: parent.width
                height: parent.height - header.height

                MediaList {
                    id: mdlist
                    anchors.fill: parent
                    clip: true
                    engine: dialog.engine
                    currentPeer: dialog.currentPeer
                    onForwardRequest: dialog.forwardRequest(inputPeer, msgIds)
                    filter: {
                        switch(typeCombo.currentIndex) {
                        case 0:
                            return Telegram.MessagesFilter.TypeInputMessagesFilterPhotoVideoDocuments
                        case 1:
                            return Telegram.MessagesFilter.TypeInputMessagesFilterPhotos
                        case 2:
                            return Telegram.MessagesFilter.TypeInputMessagesFilterVideo
                        case 3:
                            return Telegram.MessagesFilter.TypeInputMessagesFilterDocument
                        case 4:
                            return Telegram.MessagesFilter.TypeInputMessagesFilterMusic
                        case 5:
                            return Telegram.MessagesFilter.TypeInputMessagesFilterGif
                        case 6:
                            return Telegram.MessagesFilter.TypeInputMessagesFilterUrl
                        case 7:
                            return Telegram.MessagesFilter.TypeInputMessagesFilterVoice
                        }
                    }
                }

                NormalWheelScroll {
                    flick: mdlist
                }

                PhysicalScrollBar {
                    anchors.right: parent.right
                    height: mdlist.height
                    width: 6*Devices.density
                    color: CutegramGlobals.baseColor
                    scrollArea: mdlist
                }
            }
        }
    }
}

