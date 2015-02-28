#include "asemanquickitemimagegrabber.h"

#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QSharedPointer>
#include <QPointer>

class AsemanQuickItemImageGrabberPrivate
{
public:
    QSharedPointer<QQuickItemGrabResult> result;
    QPointer<QQuickItem> item;

    QImage image;
};

AsemanQuickItemImageGrabber::AsemanQuickItemImageGrabber(QObject *parent) :
    QObject(parent)
{
    p = new AsemanQuickItemImageGrabberPrivate;
}

void AsemanQuickItemImageGrabber::setItem(QQuickItem *item)
{
    if(p->item == item)
        return;

    p->item = item;
    emit itemChanged();
}

QQuickItem *AsemanQuickItemImageGrabber::item() const
{
    return p->item;
}

QImage AsemanQuickItemImageGrabber::image() const
{
    return p->image;
}

void AsemanQuickItemImageGrabber::start()
{
    if(!p->item)
        return;

    p->result = p->item->grabToImage();
    connect(p->result.data(), SIGNAL(ready()), this, SLOT(ready()));
}

void AsemanQuickItemImageGrabber::ready()
{
    if(!p->item)
        return;
    if(!p->result)
        return;

    disconnect(p->result.data(), SIGNAL(ready()), this, SLOT(ready()));

    p->image = p->result->image();
    emit imageChanged();
}

AsemanQuickItemImageGrabber::~AsemanQuickItemImageGrabber()
{
    delete p;
}

