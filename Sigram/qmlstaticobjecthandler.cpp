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

#include "qmlstaticobjecthandler.h"

#include <QPointer>
#include <QQueue>
#include <QDebug>

class QmlStaticObjectHandlerPrivate
{
public:
    QString method;
    QPointer<QObject> obj;

    QQueue<QObject*> queue;
    QSet<QObject*> objects;
};

QmlStaticObjectHandler::QmlStaticObjectHandler(QObject *parent) :
    QObject(parent)
{
    p = new QmlStaticObjectHandlerPrivate;
}

void QmlStaticObjectHandler::setCreateMethod(const QString &m)
{
    if( p->method == m )
        return;

    p->method = m;
    emit createMethodChanged();
}

QString QmlStaticObjectHandler::createMethod() const
{
    return p->method;
}

void QmlStaticObjectHandler::setCreateObject(QObject *obj)
{
    if( p->obj == obj )
        return;

    p->obj = obj;
    p->queue.clear();

    emit createObjectChanged();
}

QObject *QmlStaticObjectHandler::createObject() const
{
    return p->obj;
}

QObject *QmlStaticObjectHandler::newObject()
{
    if( !p->queue.isEmpty() )
        return p->queue.takeFirst();

    QVariant ret;
    QMetaObject::invokeMethod( p->obj, p->method.toLatin1(), Q_RETURN_ARG(QVariant,ret) );

    QObject *ret_obj = ret.value<QObject*>();
    if( !ret_obj )
        return ret_obj;

    connect( ret_obj, SIGNAL(destroyed(QObject*)), SLOT(object_destroyed(QObject*)) );
    p->objects.insert(ret_obj);
    return ret_obj;
}

void QmlStaticObjectHandler::freeObject(QObject *obj)
{
    if( p->queue.contains(obj) )
        return;

    p->queue.append(obj);
}

void QmlStaticObjectHandler::object_destroyed(QObject *obj)
{
    p->objects.remove(obj);
    p->queue.removeAll(obj);
}

QmlStaticObjectHandler::~QmlStaticObjectHandler()
{
    delete p;
}
