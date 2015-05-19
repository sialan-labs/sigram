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

MouseArea {
    anchors.fill: flick

    property Flickable flick
    property bool animated: true
    property bool reverse: false

    property real startContentY

    NumberAnimation {
        id: animY
        target: flick
        easing.type: Easing.OutSine
        property: "contentY"
        duration: 400
        onRunningChanged: if(!running) flick.returnToBounds()
    }

    onPressed: mouse.accepted = false
    onWheel: {
        wheel.accepted = true
        var contentX = 0
        var contentY = 0

        if(!animY.running)
            startContentY = flick.contentY

        var ratio = animated? 0.7 : 0.5
        if( flick.orientation ) {
            if( flick.orientation == Qt.Horizontal )
                contentX = -wheel.angleDelta.y*ratio
            else
                contentY = -wheel.angleDelta.y*ratio
        } else {
            if( flick.flickableDirection == Flickable.VerticalFlick )
                contentY = -wheel.angleDelta.y*ratio
            else
            if( flick.flickableDirection == Flickable.HorizontalFlick )
                contentX = -wheel.angleDelta.y*ratio
            else {
                contentY = -wheel.angleDelta.y*ratio
                contentX = -wheel.angleDelta.x*ratio
            }
        }

        if(animated) {
            startContentY += contentY

            var padY
            if(reverse) {
                padY = flick.originY+flick.contentHeight
                if( startContentY > -flick.height+padY )
                    startContentY = -flick.height+padY
                else
                if( startContentY < -flick.contentHeight+padY )
                    startContentY = -flick.contentHeight+padY
            } else {
                padY = flick.originY
                if( startContentY < -padY )
                    startContentY = -padY
                else
                if( startContentY > flick.contentHeight - flick.height + padY )
                    startContentY = flick.contentHeight - flick.height + padY
            }

            animY.from = flick.contentY;
            animY.to = startContentY;
            animY.restart();

            flick.contentX += contentX
        } else {
            flick.contentY += contentY
            flick.contentX += contentX
            flick.returnToBounds()
        }
    }
}
