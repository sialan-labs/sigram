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

#ifndef ASEMANQTLOGGER_H
#define ASEMANQTLOGGER_H

#include <QObject>

class AsemanQtLoggerPrivate;
class AsemanQtLogger : public QObject
{
    Q_OBJECT
public:
    AsemanQtLogger(const QString & path, QObject *parent = 0);
    ~AsemanQtLogger();

    virtual void logMsg(QtMsgType type , const QMessageLogContext &context, const QString &msg);

public slots:
    void debug( const QVariant & var );

private slots:
    void app_closed();

private:
    AsemanQtLoggerPrivate *p;
};

#endif // ASEMANQTLOGGER_H
