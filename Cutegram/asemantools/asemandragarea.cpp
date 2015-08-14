#include "asemandragarea.h"

#include <QMouseEvent>
#include <QPoint>
#include <QDebug>

enum GrabState {
    Grabbed,
    NotGrabbed,
    Unknown
};

class AsemanDragAreaPrivate
{
public:
    GrabState state;
    QPoint pin;
    int minimum;
    int orientation;
    QPoint position;
};

AsemanDragArea::AsemanDragArea(QQuickItem *parent) :
    QQuickItem(parent)
{
    p = new AsemanDragAreaPrivate;
    p->state = Unknown;
    p->minimum = 10;
    p->orientation = Qt::Horizontal;
    setFiltersChildMouseEvents(true);
}

void AsemanDragArea::setMinimum(int min)
{
    if(p->minimum == min)
        return;

    p->minimum = min;
    emit minimumChanged();
}

int AsemanDragArea::minimum() const
{
    return p->minimum;
}

void AsemanDragArea::setOrientation(int ori)
{
    if(p->orientation == ori)
        return;

    p->orientation = ori;
    emit orientationChanged();
}

int AsemanDragArea::orientation() const
{
    return p->orientation;
}

int AsemanDragArea::mouseX() const
{
    return p->position.x();
}

int AsemanDragArea::mouseY() const
{
    return p->position.y();
}

bool AsemanDragArea::childMouseEventFilter(QQuickItem *item, QEvent *e)
{
    QMouseEvent *mevent = static_cast<QMouseEvent*>(e);
    if(e->type() == QEvent::MouseMove)
    {
        if(p->state == NotGrabbed)
            return QQuickItem::childMouseEventFilter(item, e);
        else
        if(p->state == Grabbed)
        {
            p->position = mapFromItem(item, mevent->pos()).toPoint();
            emit mouseXChanged();
            emit mouseYChanged();
            emit positionChanged();
            return true;
        }
    }
    else
    if(p->state != Unknown && e->type() != QEvent::MouseButtonRelease)
        return QQuickItem::childMouseEventFilter(item, e);

    switch(static_cast<int>(mevent->type()))
    {
    case QEvent::MouseButtonPress:
        p->pin = mevent->pos();
        break;

    case QEvent::MouseButtonRelease:
        if(p->state == Grabbed)
            emit released();

        p->position = QPoint(0,0);
        p->state = Unknown;
        break;

    case QEvent::MouseMove:
    {
        const int dx = qAbs(mevent->pos().x() - p->pin.x());
        const int dy = qAbs(mevent->pos().y() - p->pin.y());
        if(dx > p->minimum)
        {
            p->state = p->orientation==Qt::Horizontal? Grabbed : NotGrabbed;
            if(p->state == Grabbed)
            {
                p->position = mapFromItem(item, mevent->pos()).toPoint();
                emit pressed();
                emit mouseXChanged();
                emit mouseYChanged();
                emit positionChanged();
            }
            return true;
        }
        else
        if(dy > p->minimum)
        {
            p->state = p->orientation==Qt::Horizontal? NotGrabbed : Grabbed;
            if(p->state == Grabbed)
            {
                p->position = mapFromItem(item, mevent->pos()).toPoint();
                emit pressed();
                emit mouseXChanged();
                emit mouseYChanged();
                emit positionChanged();
            }
            return true;
        }
    }
        break;
    }

    return QQuickItem::childMouseEventFilter(item, e);
}

AsemanDragArea::~AsemanDragArea()
{
    delete p;
}

