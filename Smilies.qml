import QtQuick 2.0

Rectangle {
    id: smilies
    width: 100
    height: 62
    color: imageBack? "#55ffffff" : "#404040"
    clip: true

    signal selected( string code )

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
    }

    GridView {
        id: slist
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        model: ListModel{}
        cellWidth: 32
        cellHeight: 32
        delegate: Rectangle {
            id: item
            width: slist.cellWidth
            height: slist.cellHeight
            color: marea.pressed? "#66ffffff" : "#00000000"

            Image {
                anchors.fill: parent
                anchors.margins: 6
                sourceSize: Qt.size(width,height)
                source: "file://" + Emojis.pathOf(key)
                smooth: true
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: smilies.selected(key)
            }
        }

        function refresh() {
            model.clear()
            var keys = Emojis.keys()
            for( var i=0; i<keys.length; i++ )
                model.append( {"key":keys[i]} )
        }

        Component.onCompleted: refresh()
    }

    PhysicalScrollBar {
        scrollArea: slist; width: 8; anchors.right: parent.right; anchors.top: slist.top;
        anchors.bottom: slist.bottom; color: "#ffffff"
    }
}
