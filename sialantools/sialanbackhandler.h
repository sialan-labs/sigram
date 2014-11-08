/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

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

#ifndef SIALANBACKHANDLER_H
#define SIALANBACKHANDLER_H

#include <QObject>
#include <QJSValue>

class SialanBackHandlerPrivate;
class SialanBackHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QObject* topHandlerObject READ topHandlerObject NOTIFY topHandlerChanged)
    Q_PROPERTY(QJSValue topHandlerMethod READ topHandlerMethod NOTIFY topHandlerChanged)

public:
    SialanBackHandler(QObject *parent = 0);
    ~SialanBackHandler();

    QObject *topHandlerObject() const;
    QJSValue topHandlerMethod() const;

public slots:
    void pushHandler( QObject *obj, QJSValue jsv );
    void pushDownHandler( QObject *obj, QJSValue jsv );
    void removeHandler( QObject *obj );

    QObject *tryPopHandler();
    QObject *forcePopHandler();

    bool back();

signals:
    void topHandlerChanged();

private slots:
    void object_destroyed( QObject *obj );

private:
    SialanBackHandlerPrivate *p;
};

#endif // SIALANBACKHANDLER_H
