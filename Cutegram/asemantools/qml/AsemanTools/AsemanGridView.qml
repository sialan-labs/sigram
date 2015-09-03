import QtQuick 2.0
import AsemanTools 1.0

GridView {
    maximumFlickVelocity: View.flickVelocity
    boundsBehavior: Flickable.StopAtBounds
    rebound: Transition {
        NumberAnimation {
            properties: "x,y"
            duration: 0
        }
    }
}

