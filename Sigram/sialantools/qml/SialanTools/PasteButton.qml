/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0

Button {
    id: dyn_paste_btn
    x: textItem? textItem.mapToItem(View.root,textRect.x,textRect.y).x - width/2 : 0
    y: textItem? textItem.mapToItem(View.root,textRect.x,textRect.y).y - height - 5*physicalPlatformScale : 0
    width: 60*physicalPlatformScale
    height: 30*physicalPlatformScale
    radius: 2*physicalPlatformScale
    normalColor: "#88333333"
    highlightColor: "#333333"
    textFont.bold: false
    textColor: "#ffffff"
    visible: textItem? true : false

    property variant textItem
    property rect textRect: textItem? textItem.cursorRectangle : Qt.rect(0,0,0,0)

    onClicked: if( textItem ) textItem.paste()

    Connections{
        target: SApp
        onLanguageUpdated: initTranslations()
    }

    function initTranslations(){
        dyn_paste_btn.text = qsTr("Paste")
    }

    Component.onCompleted: initTranslations()
}
