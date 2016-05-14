import AsemanTools 1.0
import TelegramQml 2.0
import TelegramQml 2.0 as Telegram
import QtQuick 2.4
import QtGraphicalEffects 1.0
import "../globals"
import "../awesome"

Item {
    id: combo_box

    property alias currentIndex: profilesList.currentIndex
    property bool menuVisible: false

    property ProfileManagerModel profileManager

    onMenuVisibleChanged: {
        if(menuVisible)
            BackHandler.pushHandler(menu, function(){menuVisible = false})
        else
            BackHandler.removeHandler(menu)
    }

    QtObject {
        id: privates

        property Engine engine: {
            if(!profileManager) return null
            if(currentIndex >= profileManager.count) return null
            var engine = profileManager.get(currentIndex, ProfileManagerModel.DataEngine)
            return engine
        }

        property User user: {
            var userFull = engine.our
            if(!userFull) return null
            return userFull.user
        }
    }

    MouseArea {
        id: marea
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: menuVisible = !menuVisible
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10*Devices.density
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10*Devices.density

        ProfileImage {
            width: 30*Devices.density
            height: width
            anchors.verticalCenter: parent.verticalCenter
            source: privates.user
            engine: privates.engine
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 10*Devices.fontDensity
            color: CutegramGlobals.titleBarTextsColor
            text: {
                if(privates.engine && privates.engine.phoneNumber.length == 0) return qsTr("New Account")
                if(!privates.user) return ""
                return (privates.user.firstName + " " + privates.user.lastName).trim()
            }
        }
    }

    Rectangle {
        id: open_btn
        anchors.right: row.right
        anchors.verticalCenter: parent.verticalCenter
        width: 16*Devices.density
        height: width
        radius: width/2
        color: menuVisible? "#db2424" : "transparent"

        Behavior on color {
            ColorAnimation{easing.type: Easing.OutCubic; duration: 300}
        }

        Text {
            anchors.centerIn: parent
            font.family: Awesome.family
            font.pixelSize: 12*Devices.fontDensity
            color: menuVisible? "#ffffff" : CutegramGlobals.titleBarTextsColor
            text: Awesome.fa_angle_down

            Behavior on color {
                ColorAnimation{easing.type: Easing.OutCubic; duration: 300}
            }
        }
    }

    MouseArea {
        width: 10000
        height: 10000
        anchors.centerIn: parent
        visible: menuVisible
        onClicked: BackHandler.back()
    }

    Item {
        id: menu
        width: 270*Devices.density
        height: menu_frame.height
        anchors.horizontalCenter: open_btn.horizontalCenter
        anchors.top: parent.bottom
        visible: opacity != 0
        opacity: menuVisible? 1 : 0
        scale: 0.7 + opacity*0.3
        transformOrigin: Item.Top

        Behavior on opacity {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
        }

        DropShadow {
            anchors.fill: source
            source: menu_frame
            visible: menu_frame.visible
            horizontalOffset: 1*Devices.density
            verticalOffset: 1*Devices.density
            radius: 8*Devices.density
            samples: 32
            color: "#30000000"
        }

        Item {
            id: menu_frame
            width: parent.width
            height: profilesList.height + 16*Devices.density

            Rectangle {
                anchors.fill: parent
                anchors.margins: 8*Devices.density
                radius: 3*Devices.density

                ProfilesList {
                    id: profilesList
                    width: parent.width
                    profileManager: combo_box.profileManager
                    onCloseRequest: menuVisible = false
                }
            }
        }
    }
}

