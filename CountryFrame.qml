import QtQuick 2.0

Item {
    id: cntr_frame
    width: 100
    height: 62

    signal selected( string country )

    ListView {
        id: clist
        anchors.fill: parent
        model: ListModel{}
        clip: true

        delegate: Rectangle {
            id: item
            height: 42
            width: clist.width
            color: marea.pressed? "#E65245" : "#00000000"

            CountryImage {
                id: cntr_img
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 4
                anchors.leftMargin: 10
                width: height
                countryName: name
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: cntr_img.right
                anchors.leftMargin: 8
                font.pointSize: 10
                font.family: globalNormalFontFamily
                text: name
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: cntr_frame.selected(name)
            }
        }

        function refresh() {
            model.clear()

            var cntrs = Countries.countries()
            for( var i=0; i<cntrs.length; i++ )
                model.append( {"name":cntrs[i]} )
        }

        Component.onCompleted: refresh()
    }

    PhysicalScrollBar {
        scrollArea: clist; height: clist.height; width: 8
        anchors.right: clist.right; anchors.top: clist.top; color: "#333333"
    }
}
