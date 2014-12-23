/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    Cutegram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Cutegram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef UNITYSYSTEMTRAY_H
#define UNITYSYSTEMTRAY_H

#include <QString>
#include <QHash>

class QObject;
class UnitySystemTrayPrivate;
class UnitySystemTray
{
public:
    UnitySystemTray( const QString & name, const QString & icon );
    ~UnitySystemTray();

    void addMenu( const QString & text, QObject *obj, const char *member );
    void setIcon( const QString & icon );

    void *pntr();

private:
    UnitySystemTrayPrivate *p;
};

#endif // UNITYSYSTEMTRAY_H
