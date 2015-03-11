import QtQuick 2.0
import QtQuick.Controls.Styles 1.1
import QtGraphicalEffects 1.0

ScrollViewStyle {
    handle: Rectangle {
        implicitHeight: 5
        implicitWidth: 5
        color: "#888888"
        opacity: styleData.hovered? 1 : 0.5
        radius: 5
    }

    scrollBarBackground: Item {
        implicitHeight: 5
        implicitWidth: 5
    }

    incrementControl: Item{}
    decrementControl: Item{}
}
