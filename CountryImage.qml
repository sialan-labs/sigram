import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    width: 100
    height: 62

    property string countryName
    property alias source: img.path

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: 5
        smooth: true
        visible: false
    }

    Image {
        id: img
        anchors.fill: parent
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectCrop
        smooth: true
        visible: false
        asynchronous: true
        source: path.length==0? "" : "file://" + path

        property string path: Countries.countryFlag(countryName)
    }

    ThresholdMask {
        id: threshold
        anchors.fill: img
        source: img
        maskSource: mask
        threshold: 0.4
        spread: 0.6
    }
}
