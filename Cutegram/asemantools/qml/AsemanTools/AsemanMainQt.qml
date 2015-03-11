import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Private 1.0

Rectangle {
    width: 100
    height: 62

    Component.onCompleted: {
        if(Devices.isDesktop)
            Settings.stylePath = "qrc:/asemantools/qml/AsemanTools/Controls/Styles/"
    }
}

