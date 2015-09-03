/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import AsemanTools 1.0

Rectangle {
    id: dt_chooser
    width: 400*Devices.density
    height: 150*Devices.density
    clip: true

    property color separatorColors: "#88888888"
    property color textsColor
    property bool dateVisible: true
    property bool timeVisible: true

    property alias calendarType: model.calendar

    property alias dateLabel: date_text.text
    property alias timeLabel: time_text.text

    CalendarModel {
        id: model
        onCurrentYearIndexChanged: year_list.positionViewAtIndex(currentYearIndex)
        onCurrentMonthIndexChanged: month_list.positionViewAtIndex(currentMonthIndex)
        onCurrentDaysIndexChanged: day_list.positionViewAtIndex(currentDaysIndex)
        onCurrentHoursIndexChanged: hour_list.positionViewAtIndex(currentHoursIndex)
        onCurrentMinutesIndexChanged: minute_list.positionViewAtIndex(currentMinutesIndex)

        Component.onCompleted: {
            currentYearIndexChanged()
            currentMonthIndexChanged()
            currentDaysIndexChanged()
            currentHoursIndexChanged()
            currentMinutesIndexChanged()
        }

        function save() {
            save_timer.restart()
        }
    }

    Timer {
        id: save_timer
        interval: 100
        onTriggered: {
            model.setConvertDate(year_list.currentIndex,
                                 month_list.currentIndex,
                                 day_list.currentIndex,
                                 hour_list.currentIndex,
                                 minute_list.currentIndex)
        }
    }

    Row {
        id: row
        anchors.top: date_line.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        SelectableList {
            id: year_list
            height: parent.height
            width: timeVisible? dt_chooser.width*3/14 : dt_chooser.width*75/225
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
            visible: dateVisible
            items: model.years
            onCurrentIndexChanged: model.save()
        }

        SelectableList {
            id: month_list
            height: parent.height
            width: timeVisible? dt_chooser.width*4/14 : dt_chooser.width*100/225
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
            visible: dateVisible
            nameMethodObject: model
            nameMethodFunction: "monthName"
            items: model.months
            onCurrentIndexChanged: model.save()
        }

        SelectableList {
            id: day_list
            height: parent.height
            width: timeVisible? dt_chooser.width*2/14 : dt_chooser.width*50/225
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
            visible: dateVisible
            items: model.days
            onCurrentIndexChanged: model.save()
        }

        Item {
            height: parent.height
            width: dt_chooser.width*1/14
            visible: dateVisible && timeVisible
        }

        SelectableList {
            id: hour_list
            height: parent.height
            width: dateVisible? dt_chooser.width*2/14 : dt_chooser.width*0.5
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
            visible: timeVisible
            nameMethodObject: row
            nameMethodFunction: "rightJustify"
            items: model.hours
            onCurrentIndexChanged: model.save()
        }

        SelectableList {
            id: minute_list
            height: parent.height
            width: dateVisible? dt_chooser.width*2/14 : dt_chooser.width*0.5
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
            visible: timeVisible
            nameMethodObject: row
            nameMethodFunction: "rightJustify"
            items: model.minutes
            onCurrentIndexChanged: model.save()
        }

        function rightJustify( str ) {
            var tempString = str.toString()
            while( tempString.length < 2 )
                tempString = "0" + tempString

            return tempString
        }
    }

    Rectangle {
        id: date_line
        x: 0
        height: 2*Devices.density
        width: year_list.width + month_list.width + day_list.width
        anchors.top: date_text.bottom
        visible: dateVisible
        color: separatorColors
    }

    Rectangle {
        id: time_line
        x: parent.width-width
        height: 2*Devices.density
        width: hour_list.width + minute_list.width
        anchors.top: time_text.bottom
        visible: timeVisible
        color: separatorColors
    }

    Text {
        id: date_text
        anchors.horizontalCenter: date_line.horizontalCenter
        anchors.top: parent.top
        font.family: AsemanApp.globalFont.family
        font.pixelSize: Math.floor(10*Devices.fontDensity)
        color: dt_chooser.textsColor
        visible: dateVisible
        text: qsTr("Date")
    }

    Text {
        id: time_text
        anchors.horizontalCenter: time_line.horizontalCenter
        anchors.top: parent.top
        font.family: AsemanApp.globalFont.family
        font.pixelSize: Math.floor(10*Devices.fontDensity)
        color: dt_chooser.textsColor
        visible: timeVisible
        text: qsTr("Time")
    }

    function getDate() {
        return model.dateTime
    }
}
