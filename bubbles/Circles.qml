import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: circle
    x: (parent.width+width)*xRatio - width + privates.xSwing + privates.xBoom
    y: (parent.height+height)*yRatio - height
    width: parent.width * wRadio + 6
    height: width
    smooth: true

    property real xRatio: 0
    property real yRatio: 0
    property real wRadio: 0.1

    property alias color: back.color

    onYRatioChanged: {
        if( yRatio > 0 || !privates.animations )
            return

        privates.animations = false
        resetShape()
        yRatio = 1
        privates.yAnim = Math.random()*20000 + 10000
        privates.animations = true
        yRatio = 0
    }

    Behavior on xRatio {
        NumberAnimation { easing.type: Easing.InOutCubic; duration: privates.animations? privates.xAnim : 0 }
    }
    Behavior on yRatio {
        NumberAnimation { easing.type: privates.finishStep? Easing.OutBounce : Easing.Linear; duration: privates.animations? privates.yAnim : 0 }
    }

    QtObject {
        id: privates

        property bool animations: false
        property real xAnim: 1
        property real yAnim: 1
        property real xSwing: 0
        property real xBoom: 0
        property real boomAnim: 1
        property bool finishStep: true

        Behavior on xSwing {
            NumberAnimation { easing.type: Easing.InOutCubic; duration: privates.xAnim }
        }
        Behavior on xBoom {
            NumberAnimation { easing.type: Easing.InOutQuad; duration: privates.boomAnim }
        }
    }

    Item {
        id: back_frame
        anchors.margins: -blur.radius
        anchors.fill: parent
        visible: false

        Rectangle {
            id: back
            width: parent.width<parent.height? parent.width - blur.radius*2 : parent.height - blur.radius*2
            height: width
            anchors.centerIn: parent
            radius: width/2
        }
    }

    FastBlur {
        id: blur
        anchors.fill: back_frame
        source: back_frame
        Component.onDestruction: radius = 0
    }

    Timer {
        id: x_pos_timer
        repeat: true
        triggeredOnStart: true
        onTriggered: privates.xSwing = 300*Math.random() - 150
    }

    Timer {
        id: boom_timer
        repeat: false
        interval: privates.boomAnim
        onTriggered: privates.xBoom = 0
    }

    function boom() {
        var xBoom = parent.width/2 - Math.abs(x-parent.width/2)
        xBoom = xBoom*(0.5-Math.abs(yRatio-0.5))
        xBoom = xBoom*Math.sqrt(Math.random())

        privates.xBoom = (x>parent.width/2)? xBoom : -xBoom
        boom_timer.restart()
    }

    function start() {
        if( !privates.finishStep )
            return

        xRatio = Math.random()
        yRatio = Math.random()
        resetShape()
        privates.finishStep = false
        privates.animations = true
        privates.xAnim = Math.random()*5000 + 10000
        privates.yAnim = (Math.random()*20000 + 20000)*yRatio + 5000
        privates.boomAnim = Math.random()*1000 + 1500
        x_pos_timer.interval = privates.xAnim
        x_pos_timer.start()
        yRatio = 0
    }

    function stop() {
        x_pos_timer.stop()
        privates.finishStep = true
        yRatio = yRatio + 0.0001
    }

    function resetShape() {
        wRadio = Math.pow(Math.random(),6)/10
        z = Math.random()*10
        color = Qt.hsla(Math.random(),Math.random()/2 + 0.5,0.2 + Math.random()*0.4,Math.random()/2)
        blur.radius = 64*Math.random()
    }

    function putDown() {
        stop()
        x_pos_timer.stop()
        privates.yAnim = 500 + 200*Math.random()
        xRatio = xRatio + 0.0001
        privates.xSwing = privates.xSwing + 0.0001
        yRatio = 1
    }
}
