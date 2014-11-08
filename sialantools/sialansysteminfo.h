/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    SialanTools is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SialanTools is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef SIALANSYSTEMINFO_H
#define SIALANSYSTEMINFO_H

#include <QObject>

class SialanSystemInfoPrivate;
class SialanSystemInfo : public QObject
{
    Q_OBJECT
public:
    SialanSystemInfo(QObject *parent = 0);
    ~SialanSystemInfo();

public slots:
    quint64 cpuCores();
    quint64 cpuFreq();

private:
    SialanSystemInfoPrivate *p;
};

#endif // SIALANSYSTEMINFO_H
