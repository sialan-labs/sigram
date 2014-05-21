import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: frame

    Component.onCompleted: refresh()

    QtObject{
        id: privates
        property variant list: new Array
        property real colorAnim: 300

        function stopPrev() {

        }
    }

    Timer {
        id: stop_timer
        interval: 500
        repeat: false
        onTriggered: {
            for( var i=0; i<privates.list.length; i++ )
                privates.list[i].putDown()
        }
    }

    function createCircle() {
        var component = Qt.createComponent("Circles.qml")
        var object = component.createObject(frame)
        return object
    }

    function refresh() {
        while( privates.list.length != 0 )
            privates.list.pop().destroy()

        var ar = new Array
        for( var i=0; i<50; i++ )
            ar.push( createCircle() )

        privates.list = ar
    }

    function start() {
        for( var i=0; i<privates.list.length; i++ )
            privates.list[i].start()
    }

    function show( text ) {
        boom()
    }

    function boom() {
        for( var i=0; i<privates.list.length; i++ )
            privates.list[i].boom()
    }

    function end() {
        for( var i=0; i<privates.list.length; i++ )
            privates.list[i].stop()
        stop_timer.restart()
    }
}
