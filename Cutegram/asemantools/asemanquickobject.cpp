#include "asemanquickobject.h"

#include <QSet>

QSet<AsemanQuickObject*> aseman_quick_objs;

class AsemanQuickObjectPrivate
{
public:
    QList<QObject*> items;
};

AsemanQuickObject::AsemanQuickObject(QObject *parent) :
    QObject(parent)
{
    p = new AsemanQuickObjectPrivate;
    aseman_quick_objs.insert(this);
}

QQmlListProperty<QObject> AsemanQuickObject::items()
{
    return QQmlListProperty<QObject>(this, &p->items, QQmlListProperty<QObject>::AppendFunction(append),
                                                      QQmlListProperty<QObject>::CountFunction(count),
                                                      QQmlListProperty<QObject>::AtFunction(at),
                                     QQmlListProperty<QObject>::ClearFunction(clear) );
}

bool AsemanQuickObject::isValid(AsemanQuickObject *obj)
{
    return aseman_quick_objs.contains(obj);
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
    aseman_quick_objs.remove(this);
    delete p;
}

