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

#include "setobject.h"

#include <QSet>

class SetObjectPrivate
{
public:
    QSet<QString> data;
};

SetObject::SetObject(QObject *parent) :
    QObject(parent)
{
    p = new SetObjectPrivate;
}

void SetObject::insert(const QString &str)
{
    p->data.insert(str);
}

void SetObject::remove(const QString &str)
{
    p->data.remove(str);
}

bool SetObject::contains(const QString &str)
{
    return p->data.contains(str);
}

QStringList SetObject::exportData() const
{
    return p->data.toList();
}

QList<int> SetObject::exportIntData() const
{
    QList<int> res;
    foreach( const QString & str, p->data )
        res << str.toInt();

    return res;
}

void SetObject::importData(const QStringList &data)
{
    p->data = data.toSet();
}

void SetObject::appendData(const QStringList &data)
{
    p->data.unite( data.toSet() );
}

SetObject::~SetObject()
{
    delete p;
}
