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

#include "asemanbackhandler.h"
#include "asemantools.h"

#include <QPair>
#include <QStack>
#include <QDebug>

class AsemanHandlerItem
{
public:
    QObject *obj;
    QJSValue jsv;
};

class AsemanBackHandlerPrivate
{
public:
    QStack<AsemanHandlerItem> stack;
};

AsemanBackHandler::AsemanBackHandler(QObject *parent) :
    QObject(parent)
{
    p = new AsemanBackHandlerPrivate;
}

QObject *AsemanBackHandler::topHandlerObject() const
{
    if( p->stack.isEmpty() )
        return 0;

    return p->stack.top().obj;
}

QJSValue AsemanBackHandler::topHandlerMethod() const
{
    if( p->stack.isEmpty() )
        return QString();

    return p->stack.top().jsv;
}

void AsemanBackHandler::pushHandler(QObject *obj, QJSValue jsv)
{
    AsemanHandlerItem item;
    item.obj = obj;
    item.jsv = jsv;

    p->stack.push( item );

    connect( obj, SIGNAL(destroyed(QObject*)), SLOT(object_destroyed(QObject*)) );
}

void AsemanBackHandler::pushDownHandler(QObject *obj, QJSValue jsv)
{
    AsemanHandlerItem item;
    item.obj = obj;
    item.jsv = jsv;

    p->stack.prepend( item );

    connect( obj, SIGNAL(destroyed(QObject*)), SLOT(object_destroyed(QObject*)) );
}

void AsemanBackHandler::removeHandler(QObject *obj)
{
    for( int i=p->stack.count()-1; i>=0; i-- )
        if( p->stack.at(i).obj == obj )
        {
            p->stack.removeAt(i);
            break;
        }
}

QObject *AsemanBackHandler::tryPopHandler()
{
    if( p->stack.isEmpty() )
        return 0;

    AsemanHandlerItem item = p->stack.top();
    const int count = p->stack.count();

    const QJSValue & res = item.jsv.call();
    if( !res.isUndefined() && res.toBool() == false )
        return 0;

    if( p->stack.count() == count )
        p->stack.pop();

    return item.obj;
}

QObject *AsemanBackHandler::forcePopHandler()
{
    if( p->stack.isEmpty() )
        return 0;

    AsemanHandlerItem item = p->stack.top();
    const int count = p->stack.count();

    item.jsv.call();
    if( p->stack.count() == count )
        p->stack.pop();

    return item.obj;
}

bool AsemanBackHandler::back()
{
    if( p->stack.isEmpty() )
        return false;

    tryPopHandler();
    return true;
}

void AsemanBackHandler::object_destroyed(QObject *obj)
{
    for( int i=0; i<p->stack.count(); i++ )
        if( p->stack.at(i).obj == obj )
        {
            p->stack.removeAt(i);
            i--;
        }
}

AsemanBackHandler::~AsemanBackHandler()
{
    delete p;
}
