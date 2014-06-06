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

Item {
    id: frame

    Component.onCompleted: refresh()

    QtObject{
        id: privates
        property variant list: new Array
        property real colorAnim: 300

        function stopPrev() {

        }
    }

    Timer {
        id: stop_timer
        interval: 500
        repeat: false
        onTriggered: {
            for( var i=0; i<privates.list.length; i++ )
                privates.list[i].putDown()
        }
    }

    function createCircle() {
        var component = Qt.createComponent("SialanCircles.qml")
        var object = component.createObject(frame)
        return object
    }

    function refresh() {
        if( privates.list.length != 0 ) {
            for( var i=0; i<40; i++ )
                privates.list[i].destroy()
        }

        var ar = new Array
        for( var i=0; i<40; i++ )
            ar.push( createCircle() )

        privates.list = ar
    }

    function start() {
        for( var i=0; i<privates.list.length; i++ )
            privates.list[i].start()
    }

    function show( text ) {
        boom()
    }

    function boom() {
        for( var i=0; i<privates.list.length; i++ )
            privates.list[i].boom()
    }

    function end() {
        refresh()
        stop_timer.restart()
    }
}
