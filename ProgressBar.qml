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

import QtQuick 2.2

Rectangle {
    id: progress_bar
    width: 100
    height: 30
    color: "#0d7080"
    smooth: true

    property real frameSize: 4
    property real percent: 0
    property alias progressColor: top.color

    Rectangle {
        id: top
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: frameSize
        width: (progress_bar.width-2*frameSize)*progress_bar.percent/100
        color: "#33b7cc"
        radius: progress_bar.radius
        visible: width >= radius*2

        Behavior on width {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 500 }
        }
    }

    function setValue( p ){
        percent = p
    }
}
