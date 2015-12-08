#ifndef ASEMANNETWORKSLEEPMANAGER_H
#define ASEMANNETWORKSLEEPMANAGER_H

#include <QObject>

class AsemanNetworkSleepManagerPrivate;
class AsemanNetworkSleepManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString host     READ host     WRITE setHost     NOTIFY hostChanged)
    Q_PROPERTY(qint32  port     READ port     WRITE setPort     NOTIFY portChanged)
    Q_PROPERTY(qint32  interval READ interval WRITE setInterval NOTIFY intervalChanged)

    Q_PROPERTY(bool available READ available NOTIFY availableChanged)

public:
    AsemanNetworkSleepManager(QObject *parent = 0);
    ~AsemanNetworkSleepManager();

    void setHost(const QString &host);
    QString host() const;

    void setPort(qint32 port);
    qint32 port() const;

    void setInterval(qint32 ms);
    qint32 interval() const;

    bool available() const;

signals:
    void hostChanged();
    void portChanged();
    void intervalChanged();
    void wake();
    void sleep();
    void availableChanged();

private slots:
    void defaultNetworkChanged();

    void networkRecheckAll();
    void networkBearerTypeChanged();
    void networkBearerTypeFamilyChanged();
    void networkIdentifierChanged();
    void networkIsValidChanged();
    void networkStateChanged();
    void networkTypeChanged();

    void startResetTimer();
    void finishResetTimer();
    void updateAvailablity();

private:
    void setAvailable(bool stt);
    void emitAvailableChanged();

private:
    AsemanNetworkSleepManagerPrivate *p;
};

#endif // ASEMANNETWORKSLEEPMANAGER_H
