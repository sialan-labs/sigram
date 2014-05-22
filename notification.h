#ifndef NOTIFICATION_H
#define NOTIFICATION_H

#include <QObject>
#include <QStringList>

class QDBusMessage;
class NotificationPrivate;
class Notification : public QObject
{
    Q_OBJECT
public:
    Notification(QObject *parent = 0);
    ~Notification();

public slots:
    uint sendNotify(const QString & title, const QString & body, const QString & icon, uint replace_id = 0, int timeOut = 3000 , const QStringList &actions = QStringList());
    void closeNotification( uint id );

signals:
    void notifyClosed( uint id );
    void notifyTimedOut( uint id );
    void notifyAction( uint id, const QString & action );

private slots:
    void notificationClosed( const QDBusMessage & dmsg );
    void actionInvoked( const QDBusMessage & dmsg );

private:
    NotificationPrivate *p;
};

#endif // NOTIFICATION_H
