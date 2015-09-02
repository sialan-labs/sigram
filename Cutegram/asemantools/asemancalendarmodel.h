#ifndef ASEMANCALENDARMODEL_H
#define ASEMANCALENDARMODEL_H

#include <QObject>
#include <QStringList>
#include <QDateTime>

#include "asemancalendarconverter.h"

class AsemanCalendarModelPrivate;
class AsemanCalendarModel : public QObject
{
    Q_OBJECT
    Q_ENUMS(CalendarTypes)

    Q_PROPERTY(QList<int> years   READ years   NOTIFY yearsChanged)
    Q_PROPERTY(QList<int> months  READ months  NOTIFY monthsChanged)
    Q_PROPERTY(QList<int> days    READ days    NOTIFY daysChanged)
    Q_PROPERTY(QList<int> hours   READ hours   NOTIFY hoursChanged)
    Q_PROPERTY(QList<int> minutes READ minutes NOTIFY minutesChanged)

    Q_PROPERTY(int currentYearIndex    READ currentYearIndex    NOTIFY currentYearIndexChanged   )
    Q_PROPERTY(int currentMonthIndex   READ currentMonthIndex   NOTIFY currentMonthIndexChanged  )
    Q_PROPERTY(int currentDaysIndex    READ currentDaysIndex    NOTIFY currentDaysIndexChanged   )
    Q_PROPERTY(int currentHoursIndex   READ currentHoursIndex   NOTIFY currentHoursIndexChanged  )
    Q_PROPERTY(int currentMinutesIndex READ currentMinutesIndex NOTIFY currentMinutesIndexChanged)

    Q_PROPERTY(QDateTime dateTime READ dateTime WRITE setDateTime NOTIFY dateTimeChanged)
    Q_PROPERTY(int calendar READ calendar WRITE setCalendar NOTIFY calendarChanged)

    Q_PROPERTY(QDateTime minimum READ minimum WRITE setMinimum NOTIFY minimumChanged)
    Q_PROPERTY(QDateTime maximum READ maximum WRITE setMaximum NOTIFY maximumChanged)

public:

    enum CalendarTypes{
        CalendarGregorian = AsemanCalendarConverterCore::Gregorian,
        CalendarJalali = AsemanCalendarConverterCore::Jalali,
        CalendarHijri = AsemanCalendarConverterCore::Hijri
    };

    AsemanCalendarModel(QObject *parent = 0);
    ~AsemanCalendarModel();

    QList<int> years() const;
    QList<int> months() const;
    QList<int> days() const;
    QList<int> hours() const;
    QList<int> minutes() const;

    int currentYearIndex() const;
    int currentMonthIndex() const;
    int currentDaysIndex() const;
    int currentHoursIndex() const;
    int currentMinutesIndex() const;

    void setDateTime(const QDateTime &dt);
    QDateTime dateTime() const;

    void setCalendar(int t);
    int calendar() const;

    void setMinimum(const QDateTime &dt);
    QDateTime minimum() const;

    void setMaximum(const QDateTime &dt);
    QDateTime maximum() const;

public slots:
    void setConvertDate(int yearIdx, int monthIdx, int dayIdx, int hourIdx, int minuteIdx);
    QString monthName(int month);

signals:
    void yearsChanged();
    void monthsChanged();
    void daysChanged();
    void hoursChanged();
    void minutesChanged();
    void secondsChanged();
    void dateTimeChanged();
    void calendarChanged();
    void minimumChanged();
    void maximumChanged();

    void currentYearIndexChanged();
    void currentMonthIndexChanged();
    void currentDaysIndexChanged();
    void currentHoursIndexChanged();
    void currentMinutesIndexChanged();

private slots:
    void refreshLists();
    void refreshLists_prv();

private:
    AsemanCalendarModelPrivate *p;
};

#endif // ASEMANCALENDARMODEL_H
