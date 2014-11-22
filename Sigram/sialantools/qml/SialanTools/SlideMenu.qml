/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2

Item {
    id: slide_menu
    width: 100
    height: 62
    clip: true

    property variant item

    property alias color: menu.color

    onItemChanged: {
        if( item ) {
            item.parent = menu_frame
            menu.show = true
        } else {
            menu.show = false
        }
    }

    Timer{
        id: destroy_timer
        repeat: false
        interval: 400
        onTriggered: if(item) item.destroy()
    }

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
        visible: item? true : false
        onClicked: slide_menu.end()
        onWheel: wheel.accepted = true
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: menu.show? 0.5 : 0

        Behavior on opacity {
            NumberAnimation { easing.type: Easing.OutCubic; duration: destroy_timer.interval }
        }
    }

    Rectangle{
        id: menu
        width: item && show? item.width : 0
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        visible: item? true : false
        clip: true

        property bool show: false

        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
        }

        Item {
            id: menu_frame
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: item? item.width : 0
        }

        Behavior on width {
            NumberAnimation { easing.type: Easing.OutCubic; duration: destroy_timer.interval }
        }
    }

    function end(){
        destroy_timer.restart()
        menu.show = false
    }
}
