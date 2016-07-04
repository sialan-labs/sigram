import QtQuick 2.4
import AsemanTools 1.0
import "../toolkit" as ToolKit
import "../globals"

Rectangle {
    id: toolbar
    height: 43*Devices.density
    color: CutegramGlobals.titleBarColor

    property alias engine: header.engine
    property alias currentPeer: header.currentPeer
    property alias detailMode: header.detailMode

    property alias profileManager: profiles_combo.profileManager
    property alias currentProfileIndex: profiles_combo.currentIndex

    property alias refreshing: indicator.running

    signal detailRequest()
    signal mediaRequest()
    signal searchRequest(variant peer)

    Item {
        id: indicatorArea
        height: parent.height
        width: CutegramGlobals.panelWidth

        Indicator {
            id: indicator
            anchors.centerIn: parent
            indicatorSize: 16*Devices.density
            light: CutegramGlobals.titleBarIsDarkColor
            opacity: 0.7
            modern: true
        }
    }

    Item {
        anchors.left: indicatorArea.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: toolbar_separator.top

        ProfilesComboBox {
            id: profiles_combo
            anchors.left: parent.left
            anchors.right: splitter.left
            height: parent.height
            anchors.margins: 10*Devices.density
        }

        Rectangle  {
            id: splitter
            height: 21*Devices.density
            width: 1*Devices.density
            anchors.verticalCenter: parent.verticalCenter
            color: toolbar_separator.color
            x: CutegramSettings.sideBarWidth*Devices.density

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SplitHCursor
                anchors.margins: -3*Devices.density
                onMouseXChanged: {
                    var newX = splitter.x + mouseX - width/2
                    if(newX < 200*Devices.density)
                        newX = 200*Devices.density
                    else
                    if(newX > 500*Devices.density)
                        newX = 500*Devices.density

                    splitter.x = newX
                    CutegramSettings.sideBarWidth = splitter.x/Devices.density
                }
            }
        }

        DialogHeader {
            id: header
            anchors.left: splitter.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10*Devices.density
            height: parent.height
            onDetailRequest: toolbar.detailRequest()
            onMediaRequest: toolbar.mediaRequest()
            onSearchRequest: toolbar.searchRequest(peer)
        }
    }

    Rectangle {
        id: toolbar_separator
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1*Devices.density
        color: Qt.darker(parent.color, 1.1)
    }
}

