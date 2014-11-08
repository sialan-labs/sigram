/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

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
import SialanTools 1.0

Rectangle {
    id: qlist
    width: 100
    height: 62
    color: "#333333"

    property alias components: list.list
    property alias count: list.count

    property int currentIndex: -1

    property real dscale: 0.5

    onCurrentIndexChanged: {
        if( currentIndex >= list.count ) {
            currentIndex = list.count-1
            return
        }
        if( privates.lastIndex == currentIndex )
            return

        var prevItem = privates.currentItem
        var component = list.at(currentIndex)

        var startScale = (privates.lastIndex<currentIndex? 1+dscale : 1-dscale)
        var startOpacity = (privates.lastIndex<currentIndex? 0 : 1)
        var newItem = item_frame_component.createObject(ql_mainframe, {"scale": startScale, "opacity": startOpacity})
        newItem.item = component.createObject(newItem)
        newItem.scale = 1
        newItem.opacity = 1

        if( prevItem ) {
            prevItem.scale = (privates.lastIndex<currentIndex? 1-dscale : 1+dscale)
            prevItem.opacity = (privates.lastIndex<currentIndex? 1 : 0)
            prevItem.end()
        }

        privates.currentItem = newItem
        privates.lastIndex = currentIndex
    }

    QtObject {
        id: privates

        property variant currentItem
        property int lastIndex: -1
    }

    ListObject {
        id: list
    }

    Item {
        id: ql_mainframe
        anchors.fill: parent
        clip: true
    }

    Component {
        id: item_frame_component
        Item {
            id: item_frame
            width: parent.width
            height: parent.height

            property variant item

            Behavior on scale {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }
            Behavior on opacity {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            Timer {
                id: destroy_timer
                interval: 400
                onTriggered: {
                    item_frame.item.destroy()
                    item_frame.destroy()
                }
            }

            function end() {
                destroy_timer.restart()
            }
        }
    }
}
