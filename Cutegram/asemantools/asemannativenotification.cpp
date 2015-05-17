#include "asemannativenotification.h"
#include "asemannativenotificationitem.h"

class AsemanNativeNotificationPrivate
{
public:
    QHash<uint, AsemanNativeNotificationItem*> items;
    uint last_id;

    QColor color;
};

AsemanNativeNotification::AsemanNativeNotification(QObject *parent) :
    QObject(parent)
{
    p = new AsemanNativeNotificationPrivate;
    p->last_id = 1000;
}

void AsemanNativeNotification::setColor(const QColor &color)
{
    if(p->color == color)
        return;

    p->color = color;
    emit colorChanged();
}

QColor AsemanNativeNotification::color() const
{
    return p->color;
}

uint AsemanNativeNotification::sendNotify(const QString &title, const QString &body, const QString &icon, uint replace_id, int timeOut, const QStringList &actions)
{
    uint result = replace_id;

    AsemanNativeNotificationItem *item = p->items.value(replace_id);
    if(!item)
    {
        item = new AsemanNativeNotificationItem();
        item->setFixedWidth(400);
        item->setColor(p->color);

        p->items.insert(p->last_id, item);

        result = p->last_id;
        p->last_id++;

        connect(item, SIGNAL(destroyed()), SLOT(itemClosed()) );
        connect(item, SIGNAL(actionTriggered(QString)), SLOT(actionTriggered(QString)) );
    }

    item->setTitle(title);
    item->setBody(body);
    item->setIcon(icon);
    item->setActions(actions);
    item->setTimeOut(timeOut);
    item->show();

    return result;
}

void AsemanNativeNotification::closeNotification(uint id)
{
    AsemanNativeNotificationItem *item = p->items.value(id);
    if(!id)
        return;

    item->close();
}

void AsemanNativeNotification::itemClosed()
{
    AsemanNativeNotificationItem *item = static_cast<AsemanNativeNotificationItem*>(sender());
    if(!item)
        return;

    uint id = p->items.key(item);
    if(!id)
        return;

    p->items.remove(id);
    emit notifyClosed(id);
}

void AsemanNativeNotification::actionTriggered(const QString &action)
{
    AsemanNativeNotificationItem *item = static_cast<AsemanNativeNotificationItem*>(sender());
    if(!item)
        return;

    uint id = p->items.key(item);
    if(!id)
        return;

    emit notifyAction(id, action);
    item->close();
}

AsemanNativeNotification::~AsemanNativeNotification()
{
    delete p;
}
