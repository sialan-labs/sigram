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
import QtGraphicalEffects 1.0

Item {
    id: contact_image
    width: 62
    height: 62

    property alias source: img.path
    property color borderColor: "#333333"
    property bool onlineState: false

    property int uid

    Connections {
        target: Telegram
        onUserPhotoChanged: {
            if( user_id != uid )
                return
            img.path = Telegram.getPhotoPath(uid)
        }
        onChatPhotoChanged: {
            if( user_id != uid )
                return
            img.path = Telegram.getPhotoPath(uid)
        }
    }

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: width/2
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
        source: path.length==0? "files/unknown.jpg" : "file://" + path

        property string path: Telegram.getPhotoPath(uid)
    }

    ThresholdMask {
        id: threshold
        anchors.fill: img
        source: img
        maskSource: mask
        threshold: 0.4
        spread: 0.6
        visible: false
    }

    Desaturate {
        anchors.fill: threshold
        source: threshold
        desaturation: contact_image.onlineState? 0.0 : 1.0

        Behavior on desaturation {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 1000 }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        radius: width/2
        smooth: true
        border.color: contact_image.borderColor
        border.width: 1
        color: "#00000000"
    }
}
