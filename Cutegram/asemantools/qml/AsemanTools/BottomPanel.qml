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
    id: bpanel
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: "#D9D9D9"
    height: 0
    clip: true

    property variant item
    property bool destroyOnHide: false

    Behavior on height {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
    }

    onItemChanged: {
        if( item )
            BackHandler.pushHandler(bpanel,bpanel.hide)
        else
            BackHandler.removeHandler(bpanel)

        if( privates.oldItem )
            privates.oldItem.destroy()

        if( item ) {
            item.parent = bpanel
            item.anchors.top = bpanel.top
            item.anchors.left = bpanel.left
            item.anchors.right = bpanel.right
            bpanel.height = item.height + View.navigationBarHeight
        }

        privates.oldItem = item
    }

    QtObject {
        id: privates
        property variant oldItem
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

    function hide() {
        height = 0
        destroy_timer.restart()
    }
}
