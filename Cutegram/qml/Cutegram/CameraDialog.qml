import QtQuick 2.0
import QtQuick.Window 2.0
import AsemanTools 1.0
import QtMultimedia 5.0

Window {
    id: camera_item
    width: 500*Devices.density
    height: 430*Devices.density
    maximumWidth: width
    minimumWidth: width
    maximumHeight: height
    minimumHeight: height
    flags: Qt.Dialog
    modality: Qt.ApplicationModal
    x: View.x + View.width/2 - width/2
    y: View.y + View.height/2 - height/2

    property string currentPath

    signal selected(string path)

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Camera {
        id: camera

        imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash
        flash.mode: Camera.FlashRedEyeReduction

        exposure {
            exposureCompensation: -1.0
            exposureMode: Camera.ExposurePortrait
        }

        imageCapture {
            onImageSaved: {
                img.source = Devices.localFilesPrePath + currentPath
                img.visible = true
                camera.stop()
            }
        }
    }

    VideoOutput {
        source: camera
        anchors.fill: parent
        focus : visible
        visible: !img.visible
    }

    Image {
        id: img
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        visible: false
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10*Devices.density
        spacing: 4*Devices.density
        visible: currentPath.length != 0

        Button {
            width: 100*Devices.density
            radius: 4*Devices.density
            normalColor: "#0d80ec"
            highlightColor: Qt.darker(normalColor)
            textColor: "#ffffff"
            text: qsTr("Send")
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                camera_item.selected(currentPath)
                currentPath = ""
                camera.start()
                img.visible = false
            }
        }

        Button {
            width: 100*Devices.density
            radius: 4*Devices.density
            highlightColor: Qt.darker(normalColor)
            normalColor: "#C81414"
            textColor: "#ffffff"
            text: qsTr("Cancel")
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Cutegram.deleteFile(currentPath)
                currentPath = ""
                camera.start()
                img.visible = false
            }
        }
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10*Devices.density
        width: 100*Devices.density
        radius: 4*Devices.density
        highlightColor: Qt.darker(normalColor)
        normalColor: "#C81414"
        textColor: "#ffffff"
        text: qsTr("Capture")
        cursorShape: Qt.PointingHandCursor
        visible: currentPath.length == 0
        onClicked: {
            var guid = Tools.createUuid()
            guid = guid.slice(1, guid.length-1)
            var cameraPhotos = AsemanApp.homePath + "/camera"

            Tools.mkDir(cameraPhotos)

            currentPath = cameraPhotos + "/" + guid + ".jpg"
            camera.imageCapture.captureToLocation(currentPath)
        }
    }

    Component.onCompleted: {
        x = View.x + View.width/2 - width/2
        y = View.y + View.height/2 - height/2
    }
}

