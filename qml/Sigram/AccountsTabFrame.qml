import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0

Rectangle {
    id: acc_tab_frame
    width: 100
    height: 62
    color: backColor0

    Rectangle {
        anchors.fill: profiles_list
        color: backColor1
    }

    Connections {
        target: profiles
        onKeysChanged: refresh()
        Component.onCompleted: refresh()

        function refresh() {
            for( var i=0; i<profiles.count; i++ ) {
                var key = profiles.keys[i]
                if( hash.containt(key) )
                    continue

                var item = profiles.get(key)
                var acc = account_component.createObject(frame, {"accountItem": item})
                hash.insert(key, acc)
            }

            var hashKeys = hash.keys()
            for( var j=0; j>hashKeys.length; i++ ) {
                var key = hashKeys[j]
                if( profiles.containt(key) )
                    continue

                var acc = hash.value(key)
                acc.destroy()

                hash.remove(key)
            }
        }
    }

    HashObject {
        id: hash
    }

    ListView {
        id: profiles_list
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 60*physicalPlatformScale
        model: profiles
        delegate: Rectangle {
            width: profiles_list.width
            height: width
            color: marea.pressed? "#88339DCC" : (index==profiles_list.currentIndex? backColor2 : "#00000000")

            property string itemName: item.name
            property string itemNumber: item.number

            Text {
                anchors.centerIn: parent
                font.family: SApp.globalFontFamily
                font.pixelSize: 11*fontsScale
                color: textColor0
                text: item.name
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: profiles_list.currentIndex = index
            }
        }
    }

    Button {
        id: add_btn
        anchors.bottom: profiles_list.bottom
        anchors.left: profiles_list.left
        width: profiles_list.width
        height: width
        normalColor: "#00000000"
        highlightColor: "#88339DCC"
        icon: "files/add_account.png"
        iconHeight: 14*physicalPlatformScale
        onClicked: addAccount()
    }

    Item {
        id: frame
        anchors.left: profiles_list.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }

    Component {
        id: account_component
        AccountFrame {
            anchors.fill: parent
            visible: accountItem.number==profiles_list.currentItem.itemNumber
        }
    }
}
