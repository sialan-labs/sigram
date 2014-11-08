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

#include "sialancalendarconvertercore.h"

#include <QObject>

int sialan_gregorian_months_start[13]      = {0,31,59,90,120,151,181,212,243,273,304,334,365};
int sialan_gregorian_leap_months_start[13] = {0,31,60,91,121,152,182,213,244,274,305,335,366};

int sialan_jalali_months_start[13]      = {0,31,62,93,124,155,186,216,246,276,306,336,365};
int sialan_jalali_leap_months_start[13] = {0,31,62,93,124,155,186,216,246,276,306,336,366};

int sialan_hijri_months_start[13]      = {0,30,59,89,118,148,177,207,236,266,295,325,354};
int sialan_hijri_leap_months_start[13] = {0,30,59,89,118,148,177,207,236,266,295,325,355};
int sialan_hijri_leap_years[11]        = {2,5,7,10,13,16,18,21,24,26,29};

class SialanCalendarConverterCorePrivate
{
public:
    SialanCalendarConverterCore::CalendarTypes calendar;
};

SialanCalendarConverterCore::SialanCalendarConverterCore()
{
    p = new SialanCalendarConverterCorePrivate;
    p->calendar = SialanCalendarConverterCore::Gregorian;
}

void SialanCalendarConverterCore::setCalendar(SialanCalendarConverterCore::CalendarTypes t)
{
    p->calendar = t;
}

SialanCalendarConverterCore::CalendarTypes SialanCalendarConverterCore::calendar() const
{
    return p->calendar;
}

QString SialanCalendarConverterCore::paperString(const QDateTime &dt)
{
    const DateProperty & dp = getDate(dt.date());
    QString res = QString("%1, %2 %3 %4, %5").arg(dayName(dp.day_of_week)).arg(dp.day).arg(monthName(dp.month)).arg(dp.year).arg(dt.time().toString("hh:mm"));
    return res;
}

QString SialanCalendarConverterCore::littleString(const QDate &d)
{
    const DateProperty & dp = getDate(d);
    QString res = QString("%1 %2 %3").arg(dp.day).arg(monthName(dp.month)).arg(dp.year);
    return res;
}

QString SialanCalendarConverterCore::historyString(const QDate &d)
{
    const DateProperty & dp = getDate(d);
    QString res = QString("%1 %2 %3 - %4").arg(dp.year).arg(monthName(dp.month)).arg(dp.day).arg(dayName(dp.day_of_week));
    return res;
}

QString SialanCalendarConverterCore::numberString(const QDate &d)
{
    const DateProperty & dp = getDate(d);
    QString res = QString("%1 %2 %3 - %4").arg(dp.year).arg(dp.month).arg(dp.day).arg(dayName(dp.day_of_week));
    return res;
}

DateProperty SialanCalendarConverterCore::getDate(const QDate &d)
{
    DateProperty res;
    switch( static_cast<int>(p->calendar) )
    {
    case SialanCalendarConverterCore::Gregorian:
        res = toDateGregorian( fromDateGregorian(d.year(),d.month(),d.day()) );
        break;
    case SialanCalendarConverterCore::Jalali:
        res = toDateJalali( fromDateGregorian(d.year(),d.month(),d.day()) );
        break;
    case SialanCalendarConverterCore::Hijri:
        res = toDateHijri( fromDateGregorian(d.year(),d.month(),d.day()) );
        break;
    }

    return res;
}

QDate SialanCalendarConverterCore::toDate(qint64 y, int m, int d)
{
    qint64 julian_zero = 0;
    switch( static_cast<int>(p->calendar) )
    {
    case SialanCalendarConverterCore::Gregorian:
        julian_zero = fromDateGregorian(y,m,d);
        break;
    case SialanCalendarConverterCore::Jalali:
        julian_zero = fromDateJalali(y,m,d);
        break;
    case SialanCalendarConverterCore::Hijri:
        julian_zero = fromDateHijri(y,m,d);
        break;
    }

    const DateProperty & pr = toDateGregorian(julian_zero);
    return QDate(pr.year,pr.month,pr.day);
}

QString SialanCalendarConverterCore::dayName(int d)
{
    QString res;
    switch( static_cast<int>(p->calendar) )
    {
    case SialanCalendarConverterCore::Gregorian:
        res = dayNameGregorian(d);
        break;
    case SialanCalendarConverterCore::Jalali:
        res = dayNameJalali(d);
        break;
    case SialanCalendarConverterCore::Hijri:
        res = dayNameHijri(d);
        break;
    }

    return res;
}

QString SialanCalendarConverterCore::monthName(int m)
{
    QString res;
    switch( static_cast<int>(p->calendar) )
    {
    case SialanCalendarConverterCore::Gregorian:
        res = monthNamesGregorian(m);
        break;
    case SialanCalendarConverterCore::Jalali:
        res = monthNamesJalali(m);
        break;
    case SialanCalendarConverterCore::Hijri:
        res = monthNamesHijri(m);
        break;
    }

    return res;
}

bool SialanCalendarConverterCore::yearIsLeap(qint64 year)
{
    bool res = false;
    switch( static_cast<int>(p->calendar) )
    {
    case SialanCalendarConverterCore::Gregorian:
        res = isLeapGregorian(year);
        break;
    case SialanCalendarConverterCore::Jalali:
        res = isLeapJalali(year);
        break;
    case SialanCalendarConverterCore::Hijri:
        res = leapIndexHijri(year) != -1;
        break;
    }

    return res;
}

int SialanCalendarConverterCore::daysOfMonth(qint64 y, int m)
{
    if( m<1 || m>12 )
        return 0;

    int res = 0;
    bool leap = yearIsLeap(y);
    switch( static_cast<int>(p->calendar) )
    {
    case SialanCalendarConverterCore::Gregorian:
        res = leap? sialan_gregorian_leap_months_start[m]-sialan_gregorian_leap_months_start[m-1] :
                sialan_gregorian_months_start[m]-sialan_gregorian_months_start[m-1];
        break;
    case SialanCalendarConverterCore::Jalali:
        res = leap? sialan_jalali_leap_months_start[m]-sialan_jalali_leap_months_start[m-1] :
                sialan_jalali_months_start[m]-sialan_jalali_months_start[m-1];
        break;
    case SialanCalendarConverterCore::Hijri:
        res = leap? sialan_hijri_leap_months_start[m]-sialan_hijri_leap_months_start[m-1] :
                sialan_hijri_months_start[m]-sialan_hijri_months_start[m-1];
        break;
    }

    return res;
}

bool SialanCalendarConverterCore::isLeapGregorian( qint64 year )
{
    return (year%4==0 && year%100!=0) || year%400==0;
}

QString SialanCalendarConverterCore::monthNamesGregorian(int m)
{
    switch( m )
    {
    case 1:
        return QObject::tr("January");
        break;
    case 2:
        return QObject::tr("February");
        break;
    case 3:
        return QObject::tr("March");
        break;
    case 4:
        return QObject::tr("April");
        break;
    case 5:
        return QObject::tr("May");
        break;
    case 6:
        return QObject::tr("June");
        break;
    case 7:
        return QObject::tr("July");
        break;
    case 8:
        return QObject::tr("August");
        break;
    case 9:
        return QObject::tr("September");
        break;
    case 10:
        return QObject::tr("October");
        break;
    case 11:
        return QObject::tr("November");
        break;
    case 12:
        return QObject::tr("December");
        break;
    }

    return QString();
}

QString SialanCalendarConverterCore::dayNameGregorian(int d)
{
    switch( d )
    {
    case 1:
        return QObject::tr("Sunday");
        break;
    case 2:
        return QObject::tr("Monday");
        break;
    case 3:
        return QObject::tr("Tuesday");
        break;
    case 4:
        return QObject::tr("Wednesday");
        break;
    case 5:
        return QObject::tr("Thuresday");
        break;
    case 6:
        return QObject::tr("Friday");
        break;
    case 7:
        return QObject::tr("Saturday");
        break;
    }

    return QString();
}

qint64 SialanCalendarConverterCore::fromDateGregorian( qint64 year , int month , int day )
{
    bool leap = isLeapGregorian( year );

    month--;
    day--;

    qint64 leap_pad = (year/4) - (year/100) + (year/400);
    qint64 year_days = year*365 + leap_pad;

    qint16 month_days = (leap)? sialan_gregorian_leap_months_start[month] : sialan_gregorian_months_start[month];
    qint64 abs_days   = year_days + month_days + day;
    if( year < 0 && !leap )
        abs_days--;

    return abs_days + 0;
}

DateProperty SialanCalendarConverterCore::toDateGregorian( qint64 days_from_gregorian_zero )
{
    days_from_gregorian_zero -= 0;

    qint64 day     = days_from_gregorian_zero;
    qint64 year    = 0;
    qint16 month   = 0;

    year += day/146097 * 400;
    day   = day%146097;

    if( days_from_gregorian_zero < 0 && day != 0 )
    {
        year -= 400;
        day   = 146097 + day;
    }

    if( day < 36524*3 )
    {
        year += day/36524 * 100;
        day   = day%36524;
    }
    else
    {
        year += 400-100;
        day   = day - 36524*3;
    }

    if( day < 1461*24 )
    {
        year += day/1461 * 4;
        day   = day%1461;
    }
    else
    {
        year += 100-4;
        day   = day - 1461*24;
    }

    if( day < 365*3 )
    {
        year += day/365 * 1;
        day   = day%365;
    }
    else
    {
        year += 4-1;
        day   = day - 365*3;
    }

    day++;

    bool leap = isLeapGregorian(year);
    for( int i=11 ; i>=0 ; i-- )
    {
        qint16 month_day = (leap)? sialan_gregorian_leap_months_start[i] : sialan_gregorian_months_start[i] ;
        if( day > month_day )
        {
            month = i;
            day  -= month_day;
            break;
        }
    }

    month++;

    DateProperty property;
        property.day = day;
        property.month = month;
        property.year = year;
        property.day_of_week = (days_from_gregorian_zero) % 7;

    if( property.day_of_week < 0 )
        property.day_of_week = 6 + property.day_of_week;
    property.day_of_week++;

    return property;
}

bool SialanCalendarConverterCore::isLeapJalali( qint64 year )
{
    return (year%4==0 && year%100!=0) || year%400==0;
}

QString SialanCalendarConverterCore::monthNamesJalali(int m)
{
    switch( m )
    {
    case 1:
        return QObject::tr("Farvardin");
        break;
    case 2:
        return QObject::tr("Ordibehesht");
        break;
    case 3:
        return QObject::tr("Khordad");
        break;
    case 4:
        return QObject::tr("Tir");
        break;
    case 5:
        return QObject::tr("Mordad");
        break;
    case 6:
        return QObject::tr("Shahrivar");
        break;
    case 7:
        return QObject::tr("Mehr");
        break;
    case 8:
        return QObject::tr("Abaan");
        break;
    case 9:
        return QObject::tr("Aazar");
        break;
    case 10:
        return QObject::tr("Dey");
        break;
    case 11:
        return QObject::tr("Bahman");
        break;
    case 12:
        return QObject::tr("Esfand");
        break;
    }

    return QString();
}

QString SialanCalendarConverterCore::dayNameJalali(int d)
{
    switch( d )
    {
    case 1:
        return QObject::tr("Shanbe");
        break;
    case 2:
        return QObject::tr("1Shanbe");
        break;
    case 3:
        return QObject::tr("2Shanbe");
        break;
    case 4:
        return QObject::tr("3Shanbe");
        break;
    case 5:
        return QObject::tr("4Shanbe");
        break;
    case 6:
        return QObject::tr("5Shanbe");
        break;
    case 7:
        return QObject::tr("Jome");
        break;
    }

    return QString();
}

qint64 SialanCalendarConverterCore::fromDateJalali( qint64 year , int month , int day )
{
    bool leap = isLeapJalali( year );

    month--;
    day--;

    qint64 leap_pad = (year/4) - (year/100) + (year/400);
    qint64 year_days = year*365 + leap_pad;

    qint16 month_days = (leap)? sialan_jalali_leap_months_start[month] : sialan_jalali_months_start[month];
    qint64 abs_days   = year_days + month_days + day;
    if( year < 0 && !leap )
        abs_days--;

    return abs_days + 226894;
}

DateProperty SialanCalendarConverterCore::toDateJalali( qint64 days_from_jalali_zero )
{
    days_from_jalali_zero -= 226894;

    qint64 day     = days_from_jalali_zero;
    qint64 year    = 0;
    qint16 month   = 0;

    year += day/146097 * 400;
    day   = day%146097;

    if( days_from_jalali_zero < 0 && day != 0 )
    {
        year -= 400;
        day   = 146097 + day;
    }

    if( day < 36524*3 )
    {
        year += day/36524 * 100;
        day   = day%36524;
    }
    else
    {
        year += 400-100;
        day   = day - 36524*3;
    }

    if( day < 1461*24 )
    {
        year += day/1461 * 4;
        day   = day%1461;
    }
    else
    {
        year += 100-4;
        day   = day - 1461*24;
    }

    if( day < 365*3 )
    {
        year += day/365 * 1;
        day   = day%365;
    }
    else
    {
        year += 4-1;
        day   = day - 365*3;
    }

    day++;

    bool leap = isLeapJalali(year);
    for( int i=11 ; i>=0 ; i-- )
    {
        qint16 month_day = (leap)? sialan_jalali_leap_months_start[i] : sialan_jalali_months_start[i] ;
        if( day > month_day )
        {
            month = i;
            day  -= month_day;
            break;
        }
    }

    month++;

    DateProperty property;
        property.day = day;
        property.month = month;
        property.year = year;
        property.day_of_week = (days_from_jalali_zero-3) % 7;

    if( property.day_of_week < 0 )
        property.day_of_week = 6 + property.day_of_week;
    property.day_of_week++;

    return property;
}

int SialanCalendarConverterCore::leapIndexHijri( qint64 year )
{
    qint8 r = year%30;
    for( int i=0 ; i<11 ; i++ )
        if( r == sialan_hijri_leap_years[i] )
            return i;

    return -1;
}

QString SialanCalendarConverterCore::monthNamesHijri( int m )
{
    switch( m )
    {
    case 1:
        return QObject::tr("Moharram");
        break;
    case 2:
        return QObject::tr("Safar");
        break;
    case 3:
        return QObject::tr("Rabiol Avval");
        break;
    case 4:
        return QObject::tr("Rabio Sani");
        break;
    case 5:
        return QObject::tr("Jamadiol Aval");
        break;
    case 6:
        return QObject::tr("Jamadio Sani");
        break;
    case 7:
        return QObject::tr("Rajab");
        break;
    case 8:
        return QObject::tr("Shaban");
        break;
    case 9:
        return QObject::tr("Ramadan");
        break;
    case 10:
        return QObject::tr("Shaval");
        break;
    case 11:
        return QObject::tr("Zighade");
        break;
    case 12:
        return QObject::tr("Zihaje");
        break;
    }

    return QString();
}

QString SialanCalendarConverterCore::dayNameHijri(int d)
{
    switch( d )
    {
    case 1:
        return QObject::tr("Saturday");
        break;
    case 2:
        return QObject::tr("Sunday");
        break;
    case 3:
        return QObject::tr("Monday");
        break;
    case 4:
        return QObject::tr("Tuesday");
        break;
    case 5:
        return QObject::tr("Wednesday");
        break;
    case 6:
        return QObject::tr("Thuresday");
        break;
    case 7:
        return QObject::tr("Friday");
        break;
    }

    return QString();
}

qint64 SialanCalendarConverterCore::leapsNumberHijri( qint64 year )
{
    qint8 r = year%30;
    for( int i=0 ; i<11 ; i++ )
        if( r <= sialan_hijri_leap_years[i] )
            return 11 * (year/30) + i + (r==sialan_hijri_leap_years[i]);

    return 0;
}

qint64 SialanCalendarConverterCore::fromDateHijri( qint64 year , int month , int day )
{
    int leap_index = leapIndexHijri( year );
    bool leap = leap_index != -1;

    month--;
    day--;

    qint64 leap_pad = leapsNumberHijri(year);

    qint64 year_days = year*354 + leap_pad;

    qint16 month_days = (leap)? sialan_hijri_leap_months_start[month] : sialan_hijri_months_start[month];
    qint64 abs_days   = year_days + month_days + day;
    if( year < 0 && !leap )
        abs_days-=11;
    if( year >= 0 && leap )
        abs_days--;

    return abs_days+227026;
}

DateProperty SialanCalendarConverterCore::toDateHijri( qint64 days_from_hijri_zero )
{
    days_from_hijri_zero -= 227026;

    qint64 day     = days_from_hijri_zero;
    qint64 year    = 0;
    qint16 month   = 0;

    year += day/10631 * 30;
    day   = day%10631;

    if( days_from_hijri_zero < 0 && day != 0 )
    {
        year -= 30;
        day   = 10631 + day;
    }

    for( int i=0 ; i<30 ; i++ )
    {
        int leap = leapIndexHijri( year );
        int year_days = (leap==-1)?354:355;
        if( day < year_days )
            break;

        year += 1;
        day  -= year_days;
    }

    day++;

    int leap_number = leapIndexHijri( year );
    bool leap = (leap_number!=-1);
    for( int i=11 ; i>=0 ; i-- )
    {
        qint16 month_day = (leap)? sialan_hijri_leap_months_start[i] : sialan_hijri_months_start[i] ;
        if( day > month_day )
        {
            month = i;
            day  -= month_day;
            break;
        }
    }

    month++;

    DateProperty property;
        property.day = day;
        property.month = month;
        property.year = year;
        property.day_of_week = (days_from_hijri_zero-4) % 7;

    if( property.day_of_week < 0 )
        property.day_of_week = 6 + property.day_of_week;
    property.day_of_week++;

    return property;
}

SialanCalendarConverterCore::~SialanCalendarConverterCore()
{
    delete p;
}
