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

    onPressed: mouse.accepted = false
    onWheel: {
        wheel.accepted = true
        if( flick.orientation ) {
            if( flick.orientation == Qt.Horizontal )
                flick.contentX -= wheel.angleDelta.y/2
            else
                flick.contentY -= wheel.angleDelta.y/2
        } else {
            if( flick.flickableDirection == Flickable.VerticalFlick )
                flick.contentY -= wheel.angleDelta.y/2
            else
            if( flick.flickableDirection == Flickable.HorizontalFlick )
                flick.contentX -= wheel.angleDelta.y/2
            else {
                flick.contentY -= wheel.angleDelta.y/2
                flick.contentX -= wheel.angleDelta.x/2
            }
        }

        flick.returnToBounds()
    }
}
