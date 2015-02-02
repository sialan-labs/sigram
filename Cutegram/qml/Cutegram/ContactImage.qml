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

    property Telegram telegram: telegramObject
    property Dialog dialog

    property bool isChat: dialog.peer.chatId != 0
    property User user: dialog? telegram.user(dialog.encrypted?enChatUid:dialog.peer.userId) : telegram.nullUser
    property Chat chat: dialog? telegram.chat(dialog.peer.chatId) : telegram.nullChat

    property EncryptedChat enchat: telegram.encryptedChat(dialog?dialog.peer.userId:0)
    property int enChatUid: enchat.adminId==telegram.me? enchat.participantId : enchat.adminId

    property real typeUserStatusOffline: 0x8c703f
    property real typeUserStatusEmpty: 0x9d05049
    property real typeUserStatusOnline: 0xedb93949

    property bool circleMode: true

    property FileLocation locationObj: {
        if(isChat) {
            return chat.photo.photoSmall
        } else {
            return user.photo.photoSmall
        }
    }

    onLocationObjChanged: telegram.getFile(locationObj)

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
        smooth: true
        source: {
            if(user.id == telegram.cutegramId)
                return "files/icon-normal.png"
            if(imgPath.length==0 && isChat)
                return "files/group.png"
            else
            if(imgPath.length==0)
                return "files/user.png"
            else
                return imgPath
        }
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        visible: !circleMode

        property string imgPath: locationObj.download.location
    }

    OpacityMask {
        id: threshold
        anchors.fill: img
        source: img
        maskSource: mask
        visible: circleMode
        smooth: true
    }
}

