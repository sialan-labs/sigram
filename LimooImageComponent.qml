/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0

Item {
    id: item
    width: 100
    height: 62

    property string source

    property bool zoomed: privates.zoom != 1

    signal rightClick( int mouseX, int mouseY )

    QtObject {
        id: privates

        property size imageSize: Gui.imageSize(item.source)
        property real imageRatio: imageSize.width/imageSize.height
        property real itemRatio: flick.width/flick.height
        property real zoom: 1
        property real maximumZoom: (imageRatio>itemRatio? imageSize.width/flick.width : imageSize.height/flick.height)*4
        property bool largeImageLoadedOnce: false

        onZoomChanged: if( zoom > 1 ) largeImageLoadedOnce = true
    }

    Rectangle {
        id: limoo_title
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 53
        color: imageBack? "#88cccccc" : "#555555"

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: y
            font.pointSize: 11
            font.weight: Font.Normal
            font.family: globalNormalFontFamily
            color: imageBack? "#333333" : "#cccccc"
            text: qsTr("Limoo image viewer")
        }
    }

    Flickable {
        id: flick
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: limoo_title.bottom
        anchors.bottom: parent.bottom
        contentWidth: width
        contentHeight: height
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        interactive: privates.zoom != 1
        clip: true

        Item {
            width: flick.contentWidth
            height: flick.contentHeight

            Image {
                id: img
                width: parent.width
                height: parent.height
                sourceSize: privates.zoom==1 && !privates.largeImageLoadedOnce? Qt.size(width,height) : privates.imageSize
                asynchronous: false
                source: privates.zoom==1 && !privates.largeImageLoadedOnce? "" : "file://" + item.source
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: privates.zoom!=1
            }

            Image {
                id: preview_img
                width: flick.width
                height: flick.height
                sourceSize: Qt.size(width,height)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                source: "file://" + item.source
                visible: privates.zoom==1
            }

            MouseArea {
                id: marea
                hoverEnabled: true
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.RightButton) {
                        item.rightClick(mouseX,mouseY)
                    }
                }
                onWheel: {
                    var point = Qt.point(wheel.x,wheel.y)
                    if (wheel.angleDelta.y > 0)
                        zoomIn(point);
                    else
                        zoomOut(point);
                }
            }
        }
    }

    ScrollBar {
        scrollArea: flick; height: flick.height; width: 8; orientation: Qt.Vertical
        anchors.right: flick.right; anchors.top: flick.top; color: "#ffffff"
    }
    ScrollBar {
        scrollArea: flick; width: flick.width; height: 8; orientation: Qt.Horizontal
        anchors.bottom: flick.bottom; anchors.left: flick.left; color: "#ffffff"
    }

    Text {
        id: zoom_percent
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8*physicalPlatformScale
        text: Math.floor(100*paintedWidth/privates.imageSize.width) + "%"
        color: "#ffffff"
        opacity: 0
        visible: opacity != 0
        onOpacityChanged: if(opacity == 1) hide_zp_timer.restart()
        onTextChanged: if(img.paintedWidth!=0) opacity = 1
        style: Text.Outline
        styleColor: "#666666"

        property real paintedWidth: img.paintedWidth==0? preview_img.paintedWidth : img.paintedWidth

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        Timer {
            id: hide_zp_timer
            interval: 1000
            repeat: false
            onTriggered: zoom_percent.opacity = 0
        }
    }

    function zoomIn(point) {
        var newZ = privates.zoom*1.2
        if( newZ > privates.maximumZoom )
            newZ = privates.maximumZoom
        if( newZ < 1 )
            newZ = 1

        privates.zoom = newZ
        refreshZoom(point)
    }

    function zoomOut(point) {
        var newZ = privates.zoom/1.2
        if( newZ < 1 )
            newZ = 1

        privates.zoom = newZ
        refreshZoom(point)
    }

    function refreshZoom(point){
        var newW = preview_img.paintedWidth*privates.zoom
        var newH = preview_img.paintedHeight*privates.zoom
        if( newW<flick.width )
            newW = flick.width
        else
        if( newH<flick.height )
            newH = flick.height

        flick.resizeContent(newW, newH, point)
        flick.returnToBounds()
    }

    function unzoom() {
        if( privates.zoom == 1 )
            return

        privates.zoom = 1
        refreshZoom(Qt.point(0,0))
    }
}
