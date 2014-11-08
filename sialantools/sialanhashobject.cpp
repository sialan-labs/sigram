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

#include "sialanhashobject.h"

#include <QList>
#include <QPair>
#include <QDebug>
#include <QDebug>

class SialanHashObjectPrivate
{
public:
    QMultiHash<QString,QVariant> hash;
};

SialanHashObject::SialanHashObject(QObject *parent) :
    QObject(parent)
{
    p = new SialanHashObjectPrivate;
}

void SialanHashObject::insert(const QString &key, const QVariant &value)
{
    p->hash.insert(key,value);
}

void SialanHashObject::insertMulti(const QString &key, const QVariant &value)
{
    p->hash.insertMulti(key,value);
}

void SialanHashObject::remove(const QString &key)
{
    p->hash.remove(key);
}

void SialanHashObject::remove(const QString &key, const QVariant &value)
{
    p->hash.remove(key,value);
}

QVariant SialanHashObject::key(const QVariant &value)
{
    return p->hash.key(value);
}

QStringList SialanHashObject::keys(const QVariant &value)
{
    return p->hash.keys(value);
}

QStringList SialanHashObject::keys()
{
    return p->hash.keys();
}

QVariant SialanHashObject::value(const QString &key)
{
    return p->hash.value(key);
}

QVariantList SialanHashObject::values(const QString &key)
{
    return p->hash.values(key);
}

QVariant SialanHashObject::containt(const QString &key)
{
    return p->hash.contains(key);
}

QVariant SialanHashObject::containt(const QString &key, const QVariant &value)
{
    return p->hash.contains(key,value);
}

void SialanHashObject::clear()
{
    p->hash.clear();
}

int SialanHashObject::count()
{
    return p->hash.count();
}

SialanHashObject::~SialanHashObject()
{
    delete p;
}
