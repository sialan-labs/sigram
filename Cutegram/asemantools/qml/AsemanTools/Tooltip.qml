/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import AsemanTools 1.0

Rectangle {
    id: tooltip
    width: txt.width + padding*2
    height: txt.height + padding*1.5
    radius: 3*Devices.density
    smooth: true
    opacity: 0
    color: "#333333"
    visible: opacity != 0

    property int interval: 1500
    property real padding: 8*Devices.density

    Behavior on opacity {
        NumberAnimation { id: anim_item; easing.type: Easing.OutCubic; duration: 250 }
    }

    Text{
        id: txt
        x: tooltip.padding
        y: tooltip.padding*0.75
        font.pixelSize: Math.floor(10*Devices.fontDensity)
        font.family: AsemanApp.globalFont.family
        color: "#ffffff"
    }

    Timer{
        id: hide_timer
        interval: tooltip.interval + 250
        repeat: false
        onTriggered: tooltip.opacity = 0
    }

    function showText( text ){
        txt.text = text
        opacity = 0.9
        hide_timer.restart()
    }
}
