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
import org.sialan.telegram 1.0

Rectangle {
    id: start_page
    width: 100
    height: 62

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
    }

    Authenticating {
        id: auth
        anchors.fill: parent
    }

    Column {
        id: connecting_frame
        width: connecting_text.width
        spacing: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        visible: Telegram.waitAndGet == Enums.NoWaitAndGet || finished_timer.running

        onVisibleChanged: {
            if( visible )
                indict.start()
            else
                indict.stop()
        }

        Indicator {
            id: indict
            width: parent.width
            height: indicatorSize
            indicatorSize: 32
            source: "files/indicator_light.png"
            Component.onCompleted: start()
        }

        Text {
            id: connecting_text
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Connecting...")
            font.family: globalNormalFontFamily
            font.pointSize: 11
            color: "#ffffff"
        }
    }

    SialanSplash {
        id: splash
        anchors.fill: parent
        Component.onCompleted: start()
    }

    Timer {
        id: finished_timer
        interval: 4000
        onTriggered: auth.start()
    }

    Component.onCompleted: finished_timer.start()
}
