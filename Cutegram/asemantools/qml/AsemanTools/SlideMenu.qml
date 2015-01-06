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

import QtQuick 2.2
import AsemanTools 1.0

Item {
    id: slide_menu
    width: 100
    height: 62
    clip: true

    QtObject {
        id: privates
        property variant menu
    }

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
        visible: privates.menu? true : false
        onClicked: slide_menu.end()
        onWheel: wheel.accepted = true
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: privates.menu? 0.5 : 0

        Behavior on opacity {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 400 }
        }
    }

    Component {
        id: menu_component

        Item {
            id: menu
            width: item && show? item.width : 0
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            clip: true

            property bool show: false
            property variant item
            property Component itemComponent

            Behavior on width {
                NumberAnimation { easing.type: Easing.OutCubic; duration: destroy_timer.interval }
            }

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

            Timer{
                id: destroy_timer
                repeat: false
                interval: 400
                onTriggered: {
                    item.destroy()
                    menu.destroy()
                }
            }

            Component.onCompleted: {
                menu.show = true
                item = itemComponent.createObject(menu_frame)
                BackHandler.pushHandler(slide_menu, slide_menu.end)
            }

            function end(){
                destroy_timer.restart()
                menu.show = false
                BackHandler.removeHandler(menu)
            }
        }
    }

    function end(){
        if( privates.menu ) {
            privates.menu.end()
            privates.menu = 0
        }
    }

    function show( component ) {
        if( privates.menu )
            privates.menu.end()

        privates.menu = menu_component.createObject(slide_menu, {"itemComponent":component})
    }
}
