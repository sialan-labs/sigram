/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

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

#include "sialancalendarconverter.h"
#include "sialancalendarconvertercore.h"
#include "sialantools.h"

class SialanCalendarConverterPrivate
{
public:
    int calendar_type;
    SialanCalendarConverterCore *calendar;
};

SialanCalendarConverter::SialanCalendarConverter(QObject *parent) :
    QObject(parent)
{
    p = new SialanCalendarConverterPrivate;
    p->calendar_type = 0;
    p->calendar = new SialanCalendarConverterCore();
}

void SialanCalendarConverter::setCalendar(int t)
{
    if( p->calendar->calendar() == t )
        return;

    p->calendar->setCalendar( static_cast<SialanCalendarConverterCore::CalendarTypes>(t) );
    emit calendarChanged();
}

QStringList SialanCalendarConverter::calendarsID() const
{
    QStringList res;
    res << QString::number(SialanCalendarConverterCore::Gregorian);
    res << QString::number(SialanCalendarConverterCore::Jalali);
    res << QString::number(SialanCalendarConverterCore::Hijri);
    return res;
}

QString SialanCalendarConverter::calendarName(int t)
{
    switch( t )
    {
    case SialanCalendarConverterCore::Gregorian:
        return tr("Gregorian");
        break;
    case SialanCalendarConverterCore::Jalali:
        return tr("Jalali");
        break;
    case SialanCalendarConverterCore::Hijri:
        return tr("Hijri");
        break;
    }

    return QString();
}

int SialanCalendarConverter::calendar() const
{
    return p->calendar->calendar();
}

int SialanCalendarConverter::currentDays()
{
    return QDate(1,1,1).daysTo(QDate::currentDate());
}

QString SialanCalendarConverter::convertIntToStringDate(qint64 d)
{
    return convertIntToStringDate(d,"ddd MMM dd yy");
}

QString SialanCalendarConverter::convertIntToFullStringDate(qint64 d)
{
    return convertIntToStringDate(d,"ddd MMM dd yyyy");
}

QString SialanCalendarConverter::convertIntToNumStringDate(qint64 d)
{
    QDate date = QDate(1,1,1);
    date = date.addDays(d);
    return SialanTools::translateNumbers( p->calendar->numberString(date) );
}

QString SialanCalendarConverter::translateInt(qint64 d)
{
    return SialanTools::translateNumbers(QString::number(d));
}

QString SialanCalendarConverter::convertIntToStringDate(qint64 d, const QString &format)
{
    Q_UNUSED(format)
    QDate date = QDate(1,1,1);
    date = date.addDays(d);
    return SialanTools::translateNumbers( p->calendar->historyString(date) );
}

QDate SialanCalendarConverter::convertDateToGragorian(qint64 y, int m, int d)
{
    return p->calendar->toDate(y,m,d);
}

QString SialanCalendarConverter::fromMSecSinceEpoch(qint64 t)
{
    return convertDateTimeToString( QDateTime::fromMSecsSinceEpoch(t) );
}

QString SialanCalendarConverter::convertDateTimeToString(const QDateTime &dt)
{
    return SialanTools::translateNumbers( p->calendar->paperString(dt) );
}

QString SialanCalendarConverter::convertDateTimeToString(const QDateTime &dt, const QString &format)
{
    return SialanTools::translateNumbers( p->calendar->paperString(dt, format) );
}

QString SialanCalendarConverter::convertDateTimeToLittleString(const QDate &dt)
{
    return SialanTools::translateNumbers( p->calendar->littleString(dt) );
}

int SialanCalendarConverter::daysOfMonth(qint64 y, int m)
{
    return p->calendar->daysOfMonth(y,m);
}

QString SialanCalendarConverter::monthName(int m)
{
    return p->calendar->monthName(m);
}

QDateTime SialanCalendarConverter::combineDateAndTime(const QDate &date, const QTime &time)
{
    return QDateTime(date, time);
}

int SialanCalendarConverter::dateMonth(const QDate &date)
{
    return convertDate(date).month;
}

int SialanCalendarConverter::dateDay(const QDate &date)
{
    return convertDate(date).day;
}

qint64 SialanCalendarConverter::dateYear(const QDate &date)
{
    return convertDate(date).year;
}

qint64 SialanCalendarConverter::currentYear()
{
    return p->calendar->getDate(QDate::currentDate()).year;
}

int SialanCalendarConverter::currentMonth()
{
    return p->calendar->getDate(QDate::currentDate()).month;
}

int SialanCalendarConverter::currentDay()
{
    return p->calendar->getDate(QDate::currentDate()).day;
}

DateProperty SialanCalendarConverter::convertDate(const QDate &date)
{
    return p->calendar->getDate(date);
}

QDate SialanCalendarConverter::convertDaysToDate(int days)
{
    return QDate(1,1,1).addDays(days);
}

int SialanCalendarConverter::convertDateToDays(const QDate &date)
{
    return QDate(1,1,1).daysTo(date);
}

QDateTime SialanCalendarConverter::fromTime_t(uint sec)
{
    return QDateTime::fromTime_t(sec);
}

SialanCalendarConverter::~SialanCalendarConverter()
{
    delete p->calendar;
    delete p;
}
