import QtQuick 2.0
import TelegramQml 1.0
import Cutegram 1.0
import AsemanTools 1.0

Rectangle {
    width: 100
    height: 62
    color: "#222222"

    ContributorsModel {
        id: cbmodel
        files: ["about/cutegram",
                "about/telegramQml",
                "about/libqtelegram",
                "about/libqtelegram-aseman-edition",
                "about/github-contributors",
                "about/sigram",
                "about/translators"]
    }

    ListView {
        id: cblist
        anchors.fill: parent
        clip: true
        model: cbmodel
        delegate: Rectangle {
            width: cblist.width
            height: 40*Devices.density
            color: marea.pressed? "#88FF5532" : "#00000000"

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 22*Devices.density

                Text {
                    width: parent.width
                    text: model.text
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#dddddd"
                    wrapMode: Text.WrapAnywhere
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: model.link
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#888888"
                    wrapMode: Text.WrapAnywhere
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: Qt.openUrlExternally(model.link)
            }
        }

        section.property: "type"
        section.criteria: ViewSection.FullString
        section.labelPositioning: ViewSection.InlineLabels
        section.delegate: Item {
            height: 50*Devices.density
            width: cblist.width

            Text {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4*Devices.density
                anchors.leftMargin: 14*Devices.density
                text: section
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 13*Devices.fontDensity
                color: "#ffffff"
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 1
                elide: Text.ElideRight
            }
        }
    }

    NormalWheelScroll {
        flick: cblist
        animated: Cutegram.smoothScroll
    }

    PhysicalScrollBar {
        scrollArea: cblist; height: cblist.height; width: 6*Devices.density
        anchors.right: cblist.right; anchors.top: cblist.top; color: "#888888"
    }
}

