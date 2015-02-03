#ifndef ASEMANNATIVENOTIFICATION_H
#define ASEMANNATIVENOTIFICATION_H

#include <QObject>
#include <QStringList>

class AsemanNativeNotificationPrivate;
class AsemanNativeNotification : public QObject
{
    Q_OBJECT
public:
    AsemanNativeNotification(QObject *parent = 0);
    ~AsemanNativeNotification();

public slots:
    uint sendNotify(const QString & title, const QString & body, const QString & icon, uint replace_id = 0, int timeOut = 3000 , const QStringList &actions = QStringList());
    void closeNotification( uint id );

signals:
    void notifyClosed( uint id );
    void notifyTimedOut( uint id );
    void notifyAction( uint id, const QString & action );

private slots:
    void itemClosed();
    void actionTriggered(const QString &action);

private:
    AsemanNativeNotificationPrivate *p;
};

#endif // ASEMANNATIVENOTIFICATION_H
