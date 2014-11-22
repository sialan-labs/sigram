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
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Item {
    id: cl_tools
    width: 100
    height: 62
    opacity: visible? 1 : 0
    visible: show || mute

    property Dialog dialog
    property variant dId: dialog.peer.chatId!=0? dialog.peer.chatId : dialog.peer.userId

    property bool show: false
    property bool mute: telegramObject.userData.isMuted(dId)

    Behavior on opacity {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: 800 }
    }

    Connections {
        target: telegramObject.userData
        onMuteChanged: {
            if( id != cl_tools.dId )
                return

            cl_tools.mute = telegramObject.userData.isMuted(cl_tools.dId)
        }
    }

    Row {
        id: row
        anchors.fill: parent
        layoutDirection: Qt.RightToLeft

        Button {
            id: mute_btn
            anchors.top: row.top
            anchors.bottom: row.bottom
            width: height
            icon: cl_tools.mute? "files/mute.png" : "files/unmute.png"
            normalColor: "#00000000"
            highlightColor: "#00000000"
            iconHeight: height - 10
            hoverEnabled: false
            onClicked: {
                if( cl_tools.mute )
                    telegramObject.userData.removeMute(dId)
                else
                    telegramObject.userData.addMute(dId)
            }
        }
    }
}
