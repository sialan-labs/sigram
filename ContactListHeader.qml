import QtQuick 2.0

Rectangle {
    id: contact_header
    width: 100
    height: 62
    color: imageBack? "#aabbbbbb" : "#cccccc"

    signal selected( int uid )
    signal close()

    MouseArea {
        anchors.fill: parent
    }

    Button {
        id: add_btn
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 42
        icon: "files/add.png"
        iconHeight: 22
        highlightColor: "#33B7CC"
        normalColor: "#bbbbbb"
        onClicked: {
            var pnt = Gui.mapToScene( add_btn, Qt.point(add_btn.width/2,add_btn.height) )
            var obj = menu.start( add_menu_component, pnt.x, pnt.y, 253, main.height - add_btn.height/2 )
            obj.selected.connect( contact_header.selected )
            obj.close.connect( contact_header.close )
        }
    }

    Component {
        id: add_menu_component
        AddMenu {
        }
    }
}
