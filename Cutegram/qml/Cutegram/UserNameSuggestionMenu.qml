import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0
import QtGraphicalEffects 1.0

Item {
    id: uname_sgs_menu
    width: 200
    height: 200
    visible: fmodel.count != 0
    clip: true

    property alias telegram: fmodel.telegram
    property alias dialog: fmodel.dialog
    property alias keyword: fmodel.keyword

    UserNameFilterModel {
        id: fmodel
    }

    DropShadow {
        anchors.fill: source
        source: back
        radius: 8*Devices.density
        samples: 16
        horizontalOffset: 1*Devices.density
        verticalOffset: 1*Devices.density
        color: "#66111111"
    }

    Item {
        id: back
        anchors.fill: parent

        Rectangle {
            id: back_frame
            anchors.fill: parent
            anchors.topMargin: 8*Devices.density
            anchors.leftMargin: 8*Devices.density
            anchors.rightMargin: 8*Devices.density
            color: Cutegram.currentTheme.sendFrameColor
            radius: 4*Devices.density

            Rectangle {
                width: parent.width
                height: parent.radius
                anchors.bottom: parent.bottom
                color: parent.color
            }
        }
    }

    ListView {
        id: listv
        width: back_frame.width-8*Devices.density
        height: back_frame.height-4*Devices.density
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        clip: true
        model: fmodel

        highlightMoveDuration: 0
        highlight: Rectangle {
            width: listv.width
            height: 32*Devices.density
            color: Cutegram.currentTheme.masterColor
            radius: 2*Devices.density
        }

        delegate: Item {
            id: listv_item
            width: listv.width
            height: 32*Devices.density

            property User user: telegram.user(userId)

            ContactImage {
                id: profile_img
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 4*Devices.density
                width: height
                user: listv_item.user
                isChat: false
                telegram: uname_sgs_menu.telegram
            }

            Text {
                anchors.left: profile_img.right
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 4*Devices.density
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                maximumLineCount: 1
                text: user.firstName + " " + user.lastName
                color: listv.currentIndex==index? Cutegram.currentTheme.sendFrameFontHighlightColor : Cutegram.currentTheme.sendFrameFontColor
            }
        }
    }

    function down() {
        if(listv.currentIndex+1 >= listv.count)
            return

        listv.currentIndex++
    }

    function up() {
        if(listv.currentIndex-1 < 0)
            return

        listv.currentIndex--
    }

    function currentUserId() {
        return fmodel.get(listv.currentIndex)
    }
}

