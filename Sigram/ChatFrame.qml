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

Rectangle {
    width: 100
    height: 62
    clip: true

    property alias current: contact_list.current

    property alias contactList: contact_list
    property alias chatView: chat_view

    ContactList {
        id: contact_list
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 250
    }

    ChatView {
        id: chat_view
        anchors.left: contact_list.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#555555"
        current: contact_list.current
    }

    Mirror {
        id: chat_view_blur
        anchors.fill: chat_view
        source: chat_view
        opacity: forwarding==0? 0 : 1
        visible: opacity != 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            hoverEnabled: true
            onWheel: wheel.accepted = true
        }

        ForwardingPage {
            anchors.fill: parent
        }
    }
}
