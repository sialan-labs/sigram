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
    id: cl_tools
    width: 100
    height: 62
    opacity: visible? 1 : 0
    visible: show || mute

    property int uid
    property bool show: false
    property bool mute: Gui.isMuted(uid)

    Behavior on opacity {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: 800 }
    }

    Connections {
        target: Gui
        onMuted: {
            if( id != cl_tools.uid )
                return

            cl_tools.mute = Gui.isMuted(cl_tools.uid)
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
            iconHeight: height - 4
            hoverEnabled: false
            onClicked: Gui.setMute( cl_tools.uid, !cl_tools.mute )
        }
    }
}
