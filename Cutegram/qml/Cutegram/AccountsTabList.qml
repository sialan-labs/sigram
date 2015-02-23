import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

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
                    width: 12*Devices.density
                    height: width
                    color: selectColor
                }
            }

            Button {
                anchors.fill: parent
                normalColor: "#00000000"
                highlightColor: selected? normalColor : "#88339DCC"
                cursorShape: Qt.PointingHandCursor
                icon: isAddBtn? "files/add_dialog.png" : "files/telegram.png"
                iconHeight: isAddBtn? 18*Devices.density : 26*Devices.density
                tooltipText: isAddBtn? qsTr("Add Account (experimental)") : key
                tooltipFont.family: AsemanApp.globalFont.family
                tooltipFont.pixelSize: Math.floor(9*Devices.fontDensity)
                onClicked: {
                    if(isAddBtn) {
                        main.addAccount()
                    } else {
                        currentKey = key
                    }
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

