#include "asemanmacnativenotification.h"

#include <QSystemTrayIcon>
#include <QTimer>
#include <QMenu>
#include <QHash>

class AsemanMacNativeNotificationItem: public QSystemTrayIcon
{
public:
    AsemanMacNativeNotificationItem(QObject *parent): QSystemTrayIcon(parent){
        setContextMenu(new QMenu());
        show();
    }
    ~AsemanMacNativeNotificationItem(){}

    QStringList actions;
    QString icon;
};

class AsemanMacNativeNotificationPrivate
{
public:
    QStringList last_actions;

    QHash<uint, AsemanMacNativeNotificationItem*> items;
    uint last_id;
    QColor color;
};

AsemanMacNativeNotification::AsemanMacNativeNotification(QObject *parent) :
    QObject(parent)
{
    p = new AsemanMacNativeNotificationPrivate;
    p->last_id = 1000;

}

void AsemanMacNativeNotification::setColor(const QColor &color)
{
    if(p->color == color)
        return;

    p->color = color;
    emit colorChanged();
}

QColor AsemanMacNativeNotification::color() const
{
    return p->color;
}

uint AsemanMacNativeNotification::sendNotify(const QString &title, const QString &body, const QString &icon, uint replace_id, int timeOut, const QStringList &actions)
{
    uint result = replace_id;

    AsemanMacNativeNotificationItem *item = p->items.value(replace_id);
    if(!item)
    {
        item = new AsemanMacNativeNotificationItem(this);

        p->items.insert(p->last_id, item);

        result = p->last_id;
        p->last_id++;

        connect(item, SIGNAL(messageClicked()), SLOT(messageClicked())  , Qt::QueuedConnection );
        connect(item, SIGNAL(destroyed())     , SLOT(messageDestroyed()), Qt::QueuedConnection );
    }

    item->showMessage(title, body, QSystemTrayIcon::Information, timeOut);
    item->actions = actions;
    item->icon = icon;

    if(timeOut)
        QTimer::singleShot(timeOut+500, item, SLOT(deleteLater()));

    return result;
}

void AsemanMacNativeNotification::closeNotification(uint id)
{
    AsemanMacNativeNotificationItem *item = p->items.value(id);
    if(!item)
        return;

    item->deleteLater();
    p->items.remove(id);
}

void AsemanMacNativeNotification::messageClicked()
{
    AsemanMacNativeNotificationItem *item = static_cast<AsemanMacNativeNotificationItem*>(sender());
    if(!item)
        return;

    const uint id = p->items.key(item);
    if(!id)
        return;

    const QStringList & actions = item->actions;
    if(!actions.isEmpty())
        emit notifyAction(id, actions.first());

    item->deleteLater();
}

void AsemanMacNativeNotification::messageDestroyed()
{
    AsemanMacNativeNotificationItem *item = static_cast<AsemanMacNativeNotificationItem*>(sender());
    if(!item)
        return;

    const uint id = p->items.key(item);
    if(!id)
        return;

    p->items.remove(id);
}

AsemanMacNativeNotification::~AsemanMacNativeNotification()
{
    delete p;
}
