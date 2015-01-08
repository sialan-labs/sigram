#include "asemandragobject.h"
#include "asemanmimedata.h"

#include <QDrag>
#include <QPointer>
#include <QMimeData>

class AsemanDragObjectPrivate
{
public:
    QDrag *drag;

    QPointer<AsemanMimeData> mime;
    int dropAction;
};

AsemanDragObject::AsemanDragObject(QObject *parent) :
    QObject(parent)
{
    p = new AsemanDragObjectPrivate;
    p->drag = 0;
    p->dropAction = Qt::MoveAction;
}

void AsemanDragObject::setMimeData(AsemanMimeData *mime)
{
    if(p->mime == mime)
        return;

    p->mime = mime;
    emit mimeDataChanged();
}

AsemanMimeData *AsemanDragObject::mimeData() const
{
    return p->mime;
}

void AsemanDragObject::setDropAction(int act)
{
    if(p->dropAction == act)
        return;

    p->dropAction = act;
    emit dropActionChanged();
}

int AsemanDragObject::dropAction() const
{
    return p->dropAction;
}

int AsemanDragObject::start()
{
    if(p->drag)
        return -1;

    QMimeData mime;
    if(p->mime)
    {
        mime.setText(p->mime->text());
        mime.setHtml(p->mime->html());
        mime.setUrls(p->mime->urls());

        const QVariantMap &map = p->mime->dataMap();
        QMapIterator<QString,QVariant> i(map);
        while(i.hasNext())
        {
            i.next();
            mime.setData(i.key(), i.value().toByteArray());
        }
    }

    p->drag = new QDrag(this);
    p->drag->setMimeData(&mime);
    return p->drag->exec( static_cast<Qt::DropAction>(p->dropAction) );
}

AsemanDragObject::~AsemanDragObject()
{
    delete p;
}

