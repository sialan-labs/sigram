#include "asemanquickitemimagegrabber.h"

#include <QQuickItem>
#include <QSharedPointer>
#include <QPointer>
#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))
#include <QQuickItemGrabResult>
#endif

class AsemanQuickItemImageGrabberPrivate
{
public:
#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))
    QSharedPointer<QQuickItemGrabResult> result;
#endif

    QPointer<QQuickItem> item;
    QImage image;
    QUrl defaultImage;
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

void AsemanQuickItemImageGrabber::setDefaultImage(const QUrl &url)
{
    if(p->defaultImage == url)
        return;

    p->defaultImage = url;
    emit defaultImageChanged();
}

QUrl AsemanQuickItemImageGrabber::defaultImage() const
{
    return p->defaultImage;
}

QImage AsemanQuickItemImageGrabber::image() const
{
    return p->image;
}

void AsemanQuickItemImageGrabber::start()
{
    if(!p->item)
        return;

#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))
    p->result = p->item->grabToImage();
    connect(p->result.data(), SIGNAL(ready()), this, SLOT(ready()));
#else
    QMetaObject::invokeMethod(this, "ready", Qt::QueuedConnection );
#endif
}

void AsemanQuickItemImageGrabber::ready()
{
    if(!p->item)
        return;

#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))
    if(!p->result)
        return;

    disconnect(p->result.data(), SIGNAL(ready()), this, SLOT(ready()));

    p->image = p->result->image();
    emit imageChanged();
#else
    p->image = QImage(p->defaultImage.toLocalFile());
    emit imageChanged();
#endif
}

AsemanQuickItemImageGrabber::~AsemanQuickItemImageGrabber()
{
    delete p;
}

