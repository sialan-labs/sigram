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

#ifndef ASEMANHASHOBJECT_H
#define ASEMANHASHOBJECT_H

#include <QObject>
#include <QVariant>

class AsemanHashObjectPrivate;
class AsemanHashObject : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    AsemanHashObject(QObject *parent = 0);
    ~AsemanHashObject();

    Q_INVOKABLE void insert(const QString & key, const QVariant & value );
    Q_INVOKABLE void insertMulti(const QString & key, const QVariant & value );
    Q_INVOKABLE void remove( const QString & key );
    Q_INVOKABLE void remove( const QString & key, const QVariant & value );

    Q_INVOKABLE QVariant key( const QVariant & value );
    Q_INVOKABLE QStringList keys( const QVariant & value );
    Q_INVOKABLE QStringList keys();
    Q_INVOKABLE QVariant value( const QString & key );
    Q_INVOKABLE QVariantList values( const QString & key );

    Q_INVOKABLE QVariant containt( const QString & key );
    Q_INVOKABLE QVariant containt( const QString & key, const QVariant & value );

    Q_INVOKABLE void clear();

    Q_INVOKABLE int count();

signals:
    void countChanged();

private:
    AsemanHashObjectPrivate *p;
};

#endif // ASEMANHASHOBJECT_H
