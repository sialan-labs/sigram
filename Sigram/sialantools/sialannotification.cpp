/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    This Project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This Project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#define DBUS_SERVICE "org.freedesktop.Notifications"
#define DBUS_PATH    "/org/freedesktop/Notifications"
#define DBUS_OBJECT  "org.freedesktop.Notifications"
#define DBUS_CLOSED  "NotificationClosed"
#define DBUS_ACTION  "ActionInvoked"
#define DBUS_NOTIFY  "Notify"
#define DBUS_NCLOSE  "CloseNotification"

#include "sialannotification.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusArgument>
#include <QCoreApplication>
#include <QDebug>

class SialanNotificationPrivate
{
public:
    QDBusConnection *connection;

    QSet<uint> notifies;
};

SialanNotification::SialanNotification(QObject *parent) :
    QObject(parent)
{
    p = new SialanNotificationPrivate;

    p->connection = new QDBusConnection( QDBusConnection::sessionBus() );
    p->connection->connect( DBUS_SERVICE , DBUS_PATH , DBUS_OBJECT , DBUS_CLOSED , this , SLOT(notificationClosed(QDBusMessage)) );
    p->connection->connect( DBUS_SERVICE , DBUS_PATH , DBUS_OBJECT , DBUS_ACTION , this , SLOT(actionInvoked(QDBusMessage))      );
}

uint SialanNotification::sendNotify(const QString &title, const QString &body, const QString &icon, uint replace_id, int timeOut, const QStringList &actions)
{
    QVariantList args;
    args << QCoreApplication::applicationName();
    args << replace_id;
    args << icon;
    args << title;
    args << body;
    args << QVariant::fromValue<QStringList>(actions) ;
    args << QVariant::fromValue<QVariantMap>(QVariantMap());
    args << timeOut;

    QDBusMessage omsg = QDBusMessage::createMethodCall( DBUS_SERVICE , DBUS_PATH , DBUS_OBJECT , DBUS_NOTIFY );
    omsg.setArguments( args );

    const QDBusMessage & imsg = p->connection->call( omsg , QDBus::BlockWithGui );
    const QVariantList & res = imsg.arguments();
    if( res.isEmpty() )
        return 0;

    uint id_res = res.first().toUInt();
    p->notifies.insert( id_res );
    return id_res;
}

void SialanNotification::closeNotification(uint id)
{
    if( !p->notifies.contains(id) )
        return;

    QVariantList args;
    args << id;

    QDBusMessage omsg = QDBusMessage::createMethodCall( DBUS_SERVICE , DBUS_PATH , DBUS_OBJECT , DBUS_NCLOSE );
    omsg.setArguments( args );

    p->connection->call( omsg , QDBus::NoBlock );
}

void SialanNotification::notificationClosed(const QDBusMessage &dmsg)
{
    if( dmsg.type() != QDBusMessage::SignalMessage )
        return ;

    const QVariantList & args = dmsg.arguments();
    if( args.isEmpty() )
        return ;

    uint id = args.at(0).toUInt();
    if( !p->notifies.contains(id) )
        return;

    if( args.count() == 1 )
    {
        emit notifyClosed(id);
        p->notifies.remove(id);
        return;
    }

    int type = args.at(1).toInt();
    switch (type) {
    case 1:
        emit notifyTimedOut( id );
        break;

    case 2:
    default:
        emit notifyClosed( id );
        p->notifies.remove(id);
        break;
    }
}

void SialanNotification::actionInvoked(const QDBusMessage &dmsg)
{
    if( dmsg.type() != QDBusMessage::SignalMessage )
        return ;

    const QVariantList & args = dmsg.arguments();
    if( args.count() != 2 )
        return ;

    uint id = args.at(0).toUInt();
    if( !p->notifies.contains(id) )
        return;

    QString action = args.at(1).toString();
    emit notifyAction(id, action);
}

SialanNotification::~SialanNotification()
{
    delete p;
}
