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
import org.sialan.telegram 1.0

Item {
    id: auth
    width: 100
    height: 62

    property bool started: false
    property real panelWidth: 327

    Image {
        id: auth_img
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: auth.width + panelWidth
        x: frame.width/2  - panelWidth
        sourceSize: Qt.size(width,height)
        source: "files/registering_splash.jpg"
        smooth: true
        fillMode: Image.PreserveAspectCrop
    }

    Item {
        id: frame
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: auth.started? panelWidth : 0
        clip: true

        Behavior on width {
            NumberAnimation{ easing.type: Easing.OutBack; duration: 500 }
        }

        FastBlur {
            x: auth_img.x
            width: auth_img.width
            height: auth_img.height
            radius: 128
            source: auth_img
        }

        Rectangle {
            anchors.fill: parent
            color: "#66ffffff"
        }

        RegisterFrame {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: panelWidth
        }
    }

    Timer {
        id: show_timer
        interval: 1000
        onTriggered: {
            if( Telegram.waitAndGet == Enums.NoWaitAndGet )
                auth.start()
            else
                auth.started = true
        }
    }

    function start() {
        show_timer.restart()
    }
}
