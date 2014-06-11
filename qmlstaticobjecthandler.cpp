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
