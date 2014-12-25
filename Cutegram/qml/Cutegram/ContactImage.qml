/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Cutegram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Cutegram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtGraphicalEffects 1.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

Item {
    id: contact_image
    width: 100
    height: 62

    property Dialog dialog
    property bool isChat: dialog.peer.chatId != 0
    property User user: telegramObject.user(dialog.peer.userId)
    property Chat chat: telegramObject.chat(dialog.peer.chatId)

    property color borderColor: "#dddddd"

    property real typeUserStatusOffline: 0x8c703f
    property real typeUserStatusEmpty: 0x9d05049
    property real typeUserStatusOnline: 0xedb93949

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
        sourceSize: Qt.size(width,height)
        source: imgPath.length==0? (isChat?"files/group.png":"files/user.png") : imgPath
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        visible: false

        property string imgPath: isChat? chat.photo.photoSmall.download.location : user.photo.photoSmall.download.location
    }

    ThresholdMask {
        id: threshold
        anchors.fill: img
        source: img
        maskSource: mask
        threshold: 0.4
        spread: 0.6
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        radius: width/2
        smooth: true
        border.color: contact_image.borderColor
        border.width: 1*Devices.density
        color: "#00000000"
    }
}

