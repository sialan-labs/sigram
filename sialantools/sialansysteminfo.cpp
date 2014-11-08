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

#define CPU_CORE_PATH "/sys/devices/system/cpu/"
#define CPU_FREQ_PATH "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"

#include "sialansysteminfo.h"

#include <QFile>
#include <QStringList>
#include <QDir>

class SialanSystemInfoPrivate
{
public:
    quint64 cpu_cores;
    quint64 cpu_freq;
};

SialanSystemInfo::SialanSystemInfo(QObject *parent) :
    QObject(parent)
{
    p = new SialanSystemInfoPrivate;
    p->cpu_cores = 0;
    p->cpu_freq = 0;
}

quint64 SialanSystemInfo::cpuCores()
{
    if( p->cpu_cores )
        return p->cpu_cores;

    p->cpu_cores = 0;

    const QStringList & dirs = QDir(CPU_CORE_PATH).entryList(QDir::Dirs|QDir::NoDotAndDotDot);
    foreach( const QString & dir, dirs )
    {
        bool ok = false;
        const QString & left = dir.left(3);
        dir.mid(3).toInt(&ok);
        if( left == "cpu" && ok )
            p->cpu_cores++;
    }

    return p->cpu_cores;
}

quint64 SialanSystemInfo::cpuFreq()
{
    if( p->cpu_freq )
        return p->cpu_freq;
    if( !cpuCores() )
        return 0;

    QFile file(CPU_FREQ_PATH);
    if( !file.open(QFile::ReadOnly) )
        return 0;

    p->cpu_freq = QString(file.readAll()).remove("\n").toULongLong();
    return p->cpu_freq;
}

SialanSystemInfo::~SialanSystemInfo()
{
    delete p;
}
