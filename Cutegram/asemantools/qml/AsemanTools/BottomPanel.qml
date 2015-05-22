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

Item {
    id: bpanel
    anchors.fill: parent

    property variant item
    property bool destroyOnHide: false

    onItemChanged: {
        if( item )
            BackHandler.pushHandler(bpanel,bpanel.hide)
        else
            BackHandler.removeHandler(bpanel)

        if( privates.oldItem )
            privates.oldItem.destroy()

        if( item ) {
            item.parent = pbar_scene
            item.anchors.top = pbar_scene.top
            item.anchors.left = pbar_scene.left
            item.anchors.right = pbar_scene.right
            pbar_scene.destHeight = item.height + View.navigationBarHeight
            pbar_scene.height = pbar_scene.destHeight
        }

        privates.oldItem = item
    }

    QtObject {
        id: privates
        property variant oldItem
    }

    Rectangle {
        anchors.fill: parent
        color: "#88000000"
        opacity: pbar_scene.height/pbar_scene.destHeight
    }

    Rectangle {
        id: pbar_scene
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#f0f0f0"
        height: 0
        clip: true

        property real destHeight: 10

        Behavior on height {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        Timer {
            id: destroy_timer
            interval: 400
            onTriggered: {
                if(bpanel.item)
                    bpanel.item.destroy()
                if(destroyOnHide)
                    bpanel.destroy()
            }
        }
    }

    function hide() {
        pbar_scene.height = 0
        destroy_timer.restart()
    }
}
