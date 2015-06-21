import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Item {
    width: 100
    height: 62

    property alias hash: hashObject
    property alias list: listObject
    property string currentKey

    property color selectColor: "#333333"

    HashObject {
        id: hashObject
    }

    ListObject {
        id: listObject
        onCountChanged: listv.refresh()
    }

    ListView {
        id: listv
        anchors.fill: parent
        model: ListModel{}
        delegate: Item {
            width: listv.width
            height: width

            property bool isAddBtn: key.length==0
            property bool selected: currentKey==key

            Rectangle {
                anchors.fill: parent
                color: "#44ffffff"
                visible: selected
                clip: true

                Rectangle {
                    x: parent.width - width/2
                    anchors.verticalCenter: parent.verticalCenter
                    transformOrigin: Item.Center
                    rotation: 45
                    width: Cutegram.currentTheme.panelPointerHeight*Devices.density
                    height: width
                    color: selectColor
                }
            }

            Button {
                anchors.fill: parent
                normalColor: "#00000000"
                highlightColor: selected? normalColor : Qt.darker(Cutegram.currentTheme.masterColor, 1.2)
                cursorShape: Qt.PointingHandCursor
                icon: {
                    if(isAddBtn)
                        return Cutegram.currentTheme.panelLightIcon? "files/add_dialog.png" : "files/add_dialog-dark.png"
                    else
                        return Cutegram.currentTheme.panelLightIcon? "files/telegram.png" : "files/telegram-dark.png"
                }
                iconHeight: isAddBtn? 18*Devices.density : 26*Devices.density
                tooltipText: isAddBtn? qsTr("Add Account") : key
                tooltipFont.family: AsemanApp.globalFont.family
                tooltipFont.pixelSize: Math.floor(9*Devices.fontDensity)
                tooltipColor: Cutegram.currentTheme.panelTooltipBackground
                tooltipTextColor: Cutegram.currentTheme.panelTooltipTextColor
                onClicked: {
                    if(isAddBtn) {
                        main.addAccount()
                    } else {
                        currentKey = key
                    }
                }
            }

            Rectangle {
                id: badge
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 4*Devices.density
                width: 18*Devices.density
                height: width
                radius: width/2
                color: "#ff0000"
                border.color: "#44ffffff"
                border.width: 1*Devices.density
                visible: count != 0

                property int count: key.length!=0 && listObject.count>1? hash.value(key).telegramObject.unreadCount : 0

                Text {
                    anchors.centerIn: parent
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(9*Devices.fontDensity)
                    color: "#ffffff"
                    text: badge.count
                }
            }
        }

        function refresh() {
            model.clear()
            for(var i=0; i<list.count; i++) {
                var key = list.at(i)
                model.append({"key": key})

                if(i==0)
                    currentKey = key
                else
                    hash.value(key).visible = false
            }

            model.append({"key": ""})
        }
    }
}

