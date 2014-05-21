import QtQuick 2.0

Canvas {
    id: canvas
    width: 40
    height: 20

    property color fillColor: "#ffffff"

    onPaint: {
        var ctx = canvas.getContext("2d");
        ctx.save();

        ctx.fillStyle = fillColor
        ctx.beginPath();

        ctx.moveTo(0,0)
        ctx.lineTo(width,0)
        ctx.lineTo(width/2,height)
        ctx.lineTo(0,0)

        ctx.fill()
    }
}
