#ifndef ASEMANMACNATIVENOTIFICATION_H
#define ASEMANMACNATIVENOTIFICATION_H

#include <QObject>
#include <QStringList>
#include <QColor>

class QDBusMessage;
class AsemanMacNativeNotificationPrivate;
class AsemanMacNativeNotification : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)

public:
    AsemanMacNativeNotification(QObject *parent = 0);
    ~AsemanMacNativeNotification();

    void setColor(const QColor &color);
    QColor color() const;

public slots:
    uint sendNotify(const QString & title, const QString & body, const QString & icon, uint replace_id = 0, int timeOut = 3000 , const QStringList &actions = QStringList());
    void closeNotification( uint id );

signals:
    void notifyClosed( uint id );
    void notifyTimedOut( uint id );
    void notifyAction( uint id, const QString & action );
    void colorChanged();

private slots:
    void messageClicked();
    void messageDestroyed();

private:
    AsemanMacNativeNotificationPrivate *p;
};

#endif //ASEMANMACNATIVENOTIFICATION_H
