import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"
import "../thirdparty"

Item {
    property real margins: 16*Devices.density

    property bool onlyFile: false
    readonly property bool isFile: dropArea.isFile
    readonly property bool isForward: dropArea.isForward
    property alias containsDrag: dropArea.containsDrag

    onContainsDragChanged: if(!containsDrag) dropArea.isFile = false

    signal sendDocumentRequest(string path)
    signal sendPhotoRequest(string path)

    NullMouseArea {
        id: nullArea
        anchors.fill: parent
        visible: isFile && containsDrag
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        onEntered: {
            var formats = drag.formats
            var dragTypeIdx = formats.indexOf("cutegram/dragType")
            isForward = (dragTypeIdx != -1)
            if(isForward) return

            isFile = drag.urls.length
            var hasPhoto = true
            var urls = drag.urls
            for(var i=0; i<urls.length; i++)
                if(Tools.fileMime(urls[i]).indexOf("image") == -1) {
                    hasPhoto = false
                    break
                }
            onlyFile = !hasPhoto
        }
        onDropped: {
            if(!isFile || isForward)
                return
            var urls = drop.urls
            for(var i=0; i<urls.length; i++) {
                if(photoArea) {
                    sendPhotoRequest(urls[i])
                } else if(fileArea) {
                    sendDocumentRequest(urls[i])
                }
            }
        }

        property bool isFile
        property bool isForward
        readonly property bool photoArea: (drag.y<height/2 && !onlyFile) && containsDrag
        readonly property bool fileArea: (drag.y>height/2 || onlyFile) && containsDrag
    }

    Item {
        id: area1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.verticalCenter
        visible: nullArea.visible && !onlyFile

        DropShadow {
            anchors.fill: source
            source: innerArea1
            horizontalOffset: 1*Devices.density
            verticalOffset: 1*Devices.density
            radius: 8.0
            samples: 32
            opacity: 0.6
            color: dropArea.photoArea? CutegramGlobals.highlightColors : "#000000"

            Behavior on color {
                ColorAnimation{easing.type: Easing.OutCubic; duration: 300}
            }
        }

        Item {
            id: innerArea1
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                anchors.margins: margins
                anchors.bottomMargin: margins/2

                Row {
                    anchors.centerIn: parent
                    spacing: 10*Devices.density

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Awesome.family
                        font.pixelSize: 30*Devices.fontDensity
                        color: "#666666"
                        text: Awesome.fa_file_photo_o
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 20*Devices.fontDensity
                        color: "#666666"
                        text: qsTr("Drop here to send photos quickly")
                    }
                }
            }
        }
    }

    Item {
        id: area2
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: onlyFile? parent.top : parent.verticalCenter
        anchors.bottom: parent.bottom
        visible: nullArea.visible

        DropShadow {
            anchors.fill: source
            source: innerArea2
            horizontalOffset: 1*Devices.density
            verticalOffset: 1*Devices.density
            radius: 8.0
            samples: 32
            opacity: 0.6
            color: dropArea.fileArea? CutegramGlobals.highlightColors : "#000000"

            Behavior on color {
                ColorAnimation{easing.type: Easing.OutCubic; duration: 300}
            }
        }

        Item {
            id: innerArea2
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                anchors.margins: margins
                anchors.topMargin: onlyFile? margins : margins/2

                Row {
                    anchors.centerIn: parent
                    spacing: 10*Devices.density

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Awesome.family
                        font.pixelSize: 30*Devices.fontDensity
                        color: "#666666"
                        text: Awesome.fa_file
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 20*Devices.fontDensity
                        color: "#666666"
                        text: qsTr("Drop here to send as files")
                    }
                }
            }
        }
    }
}

