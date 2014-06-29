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

#include "hashobject.h"

#include <QList>
#include <QPair>
#include <QDebug>
#include <QDebug>

class HashObjectPrivate
{
public:
    QMultiHash<QString,QVariant> hash;
};

HashObject::HashObject(QObject *parent) :
    QObject(parent)
{
    p = new HashObjectPrivate;
}

void HashObject::insert(const QString &key, const QVariant &value)
{
    p->hash.insert(key,value);
}

void HashObject::insertMulti(const QString &key, const QVariant &value)
{
    p->hash.insertMulti(key,value);
}

void HashObject::remove(const QString &key)
{
    p->hash.remove(key);
}

void HashObject::remove(const QString &key, const QVariant &value)
{
    p->hash.remove(key,value);
}

QVariant HashObject::key(const QVariant &value)
{
    return p->hash.key(value);
}

QStringList HashObject::keys(const QVariant &value)
{
    return p->hash.keys(value);
}

QStringList HashObject::keys()
{
    return p->hash.keys();
}

QVariant HashObject::value(const QString &key)
{
    return p->hash.value(key);
}

QVariantList HashObject::values(const QString &key)
{
    return p->hash.values(key);
}

QVariant HashObject::containt(const QString &key)
{
    return p->hash.contains(key);
}

QVariant HashObject::containt(const QString &key, const QVariant &value)
{
    return p->hash.contains(key,value);
}

void HashObject::clear()
{
    p->hash.clear();
}

int HashObject::count()
{
    return p->hash.count();
}

HashObject::~HashObject()
{
    delete p;
}
