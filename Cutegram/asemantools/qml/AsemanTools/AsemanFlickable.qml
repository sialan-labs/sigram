import QtQuick 2.0
import AsemanTools 1.0

Flickable {
    maximumFlickVelocity: View.flickVelocity
    boundsBehavior: Flickable.StopAtBounds
    rebound: Transition {
        NumberAnimation {
            properties: "x,y"
            duration: 0
        }
    }
}

