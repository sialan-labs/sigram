#ifndef ASEMANLINUXNATIVENOTIFICATION_H
#define ASEMANLINUXNATIVENOTIFICATION_H

#include <QObject>
#include <QStringList>

class QDBusMessage;
class AsemanLinuxNativeNotificationPrivate;
class AsemanLinuxNativeNotification : public QObject
{
    Q_OBJECT
public:
    AsemanLinuxNativeNotification(QObject *parent = 0);
    ~AsemanLinuxNativeNotification();

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
    AsemanLinuxNativeNotificationPrivate *p;
};

#endif // ASEMANLINUXNATIVENOTIFICATION_H
