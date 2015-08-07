import QtQuick 2.0

Item {
    id: menuc
    width: 100
    height: 62

    property real ratio: 0
    property variant source
    property int layoutDirection: View.layoutDirection
    property real menuWidth: 200*Devices.density
    property alias isVisible: marea.isVisible

    onSourceChanged: refreshSource()
    onLayoutDirectionChanged: refreshSource()
    onRatioChanged: refresh()

    onIsVisibleChanged: {
        if(isVisible)
            BackHandler.pushHandler(menuc, menuc.close)
        else
            BackHandler.removeHandler(menuc)
    }

    Behavior on ratio {
        NumberAnimation{easing.type: Easing.OutCubic; duration: marea.animation? 400 : 0}
    }

    Item {
        width: parent.width
        height: parent.height
        transform: Scale { origin.x: width/2; origin.y: height/2; xScale: layoutDirection==Qt.LeftToRight?1:-1}

        MouseArea {
            id: marea
            width: isVisible? parent.width : 10*Devices.density
            height: parent.height

            property real pinX: 0
            property bool animation: true
            property bool isVisible: false
            property bool moved: false

            onPressed: {
                pinX = mouseX
                moved = false
            }

            onMouseXChanged: {
                if(!source)
                    return
                var delta = mouseX - pinX
                if(Math.abs(delta) < 5*Devices.density && !moved)
                    return

                moved = true
                if(isVisible) delta += menuWidth
                animation = false
                show(delta)
                animation = true
            }

            onReleased: {
                var delta = (mouseX - pinX)
                if(!moved) {
                    show(0)
                    isVisible = false
                    return
                }

                if(isVisible) delta += menuWidth
                if(delta > menuWidth*(isVisible?0.8:0.2)) {
                    show(menuWidth)
                    isVisible = true
                } else {
                    show(0)
                    isVisible = false
                }
            }

            function show(size) {
                if(size > menuWidth)
                    size = menuWidth
                if(size<0)
                    size = 0

                menuc.ratio = Math.abs(size/menuWidth)
            }
        }
    }

    function refreshSource() {
        if(!source)
            return

        switch(layoutDirection) {
        case Qt.RightToLeft:
            source.transformOrigin = Item.Left
            break

        default:
            source.transformOrigin = Item.Right
            break
        }
    }

    function refresh() {
        if(!source)
            return

        source.scale = (parent.width-menuWidth*ratio/2)/source.width
        var sourceX = menuWidth*ratio/2
        if(layoutDirection == Qt.RightToLeft)
            sourceX = -sourceX

        source.x = sourceX
    }

    function close() {
        marea.show(0)
        marea.isVisible = false
    }

    function show() {
        marea.show(menuWidth)
        marea.isVisible = true
    }
}

