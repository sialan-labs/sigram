/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

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
