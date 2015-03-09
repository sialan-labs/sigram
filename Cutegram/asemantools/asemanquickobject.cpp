#include "asemanquickobject.h"

class AsemanQuickObjectPrivate
{
public:
    QList<QObject*> items;
};

AsemanQuickObject::AsemanQuickObject(QObject *parent) :
    QObject(parent)
{
    p = new AsemanQuickObjectPrivate;
}

QQmlListProperty<QObject> AsemanQuickObject::items()
{
    return QQmlListProperty<QObject>(this, &p->items, QQmlListProperty<QObject>::AppendFunction(append),
                                                      QQmlListProperty<QObject>::CountFunction(count),
                                                      QQmlListProperty<QObject>::AtFunction(at),
                                                      QQmlListProperty<QObject>::ClearFunction(clear) );
}

void AsemanQuickObject::append(QQmlListProperty<QObject> *p, QObject *v)
{
    AsemanQuickObject *aobj = static_cast<AsemanQuickObject*>(p->object);
    aobj->p->items.append(v);
    emit aobj->itemsChanged();
}

int AsemanQuickObject::count(QQmlListProperty<QObject> *p)
{
    AsemanQuickObject *aobj = static_cast<AsemanQuickObject*>(p->object);
    return aobj->p->items.count();
}

QObject *AsemanQuickObject::at(QQmlListProperty<QObject> *p, int idx)
{
    AsemanQuickObject *aobj = static_cast<AsemanQuickObject*>(p->object);
    return aobj->p->items.at(idx);
}

void AsemanQuickObject::clear(QQmlListProperty<QObject> *p)
{
    AsemanQuickObject *aobj = static_cast<AsemanQuickObject*>(p->object);
    aobj->p->items.clear();
    emit aobj->itemsChanged();
}

AsemanQuickObject::~AsemanQuickObject()
{
    delete p;
}

