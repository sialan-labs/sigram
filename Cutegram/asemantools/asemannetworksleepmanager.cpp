#include "asemannetworksleepmanager.h"
#include "asemanhostchecker.h"
#include "asemannetworkmanager.h"
#include "asemannetworkmanageritem.h"

#include <QPointer>
#include <QTimer>
#include <QDebug>

class AsemanNetworkSleepManagerPrivate
{
public:
    AsemanHostChecker *hostCheker;
    AsemanNetworkManager *networkManager;
    QPointer<AsemanNetworkManagerItem> defaultNetwork;
    bool available;
    bool forceDisable;

    QTimer *resetTimer;
};

AsemanNetworkSleepManager::AsemanNetworkSleepManager(QObject *parent) :
    QObject(parent)
{
    p = new AsemanNetworkSleepManagerPrivate;
    p->hostCheker = new AsemanHostChecker(this);
    p->available = false;
    p->forceDisable = false;

    p->networkManager = new AsemanNetworkManager(this);

    p->resetTimer = new QTimer(this);
    p->resetTimer->setInterval(2000);
    p->resetTimer->setSingleShot(true);

    connect(p->hostCheker, SIGNAL(hostChanged()), SIGNAL(hostChanged()));
    connect(p->hostCheker, SIGNAL(portChanged()), SIGNAL(portChanged()));
    connect(p->hostCheker, SIGNAL(intervalChanged()), SIGNAL(intervalChanged()));
    connect(p->hostCheker, SIGNAL(availableChanged()), SLOT(updateAvailablity()));

    connect(p->resetTimer, SIGNAL(timeout()), SLOT(finishResetTimer()));

    connect(p->networkManager, SIGNAL(defaultNetworkChanged()), SLOT(defaultNetworkChanged()));

    defaultNetworkChanged();
    updateAvailablity();
}

void AsemanNetworkSleepManager::setHost(const QString &host)
{
    p->hostCheker->setHost(host);
}

QString AsemanNetworkSleepManager::host() const
{
    return p->hostCheker->host();
}

void AsemanNetworkSleepManager::setPort(qint32 port)
{
    p->hostCheker->setPort(port);
}

qint32 AsemanNetworkSleepManager::port() const
{
    return p->hostCheker->port();
}

void AsemanNetworkSleepManager::setInterval(qint32 ms)
{
    p->hostCheker->setInterval(ms);
}

qint32 AsemanNetworkSleepManager::interval() const
{
    return p->hostCheker->interval();
}

bool AsemanNetworkSleepManager::available() const
{
    return p->available && !p->forceDisable;
}

void AsemanNetworkSleepManager::defaultNetworkChanged()
{
    if(p->defaultNetwork)
    {
        disconnect(p->defaultNetwork, SIGNAL(bearerTypeChanged()),
                   this, SLOT(networkBearerTypeChanged()));
        disconnect(p->defaultNetwork, SIGNAL(bearerTypeFamilyChanged()),
                   this, SLOT(networkBearerTypeFamilyChanged()));
        disconnect(p->defaultNetwork, SIGNAL(identifierChanged()),
                   this, SLOT(networkIdentifierChanged()));
        disconnect(p->defaultNetwork, SIGNAL(isValidChanged()),
                   this, SLOT(networkIsValidChanged()));
        disconnect(p->defaultNetwork, SIGNAL(stateChanged()),
                   this, SLOT(networkStateChanged()));
        disconnect(p->defaultNetwork, SIGNAL(typeChanged()),
                   this, SLOT(networkTypeChanged()));
    }

    p->defaultNetwork = p->networkManager->defaultNetwork();
    if(p->defaultNetwork)
    {
        connect(p->defaultNetwork, SIGNAL(bearerTypeChanged()),
                this, SLOT(networkBearerTypeChanged()));
        connect(p->defaultNetwork, SIGNAL(bearerTypeFamilyChanged()),
                this, SLOT(networkBearerTypeFamilyChanged()));
        connect(p->defaultNetwork, SIGNAL(identifierChanged()),
                this, SLOT(networkIdentifierChanged()));
        connect(p->defaultNetwork, SIGNAL(isValidChanged()),
                this, SLOT(networkIsValidChanged()));
        connect(p->defaultNetwork, SIGNAL(stateChanged()),
                this, SLOT(networkStateChanged()));
        connect(p->defaultNetwork, SIGNAL(typeChanged()),
                this, SLOT(networkTypeChanged()));
    }
}

void AsemanNetworkSleepManager::networkRecheckAll()
{
    networkBearerTypeChanged();
    networkBearerTypeFamilyChanged();
    networkIdentifierChanged();
    networkIsValidChanged();
    networkStateChanged();
    networkTypeChanged();
}

void AsemanNetworkSleepManager::networkBearerTypeChanged()
{
    updateAvailablity();
}

void AsemanNetworkSleepManager::networkBearerTypeFamilyChanged()
{
    updateAvailablity();
}

void AsemanNetworkSleepManager::networkIdentifierChanged()
{
    startResetTimer();
}

void AsemanNetworkSleepManager::networkIsValidChanged()
{
    updateAvailablity();
}

void AsemanNetworkSleepManager::networkStateChanged()
{
    updateAvailablity();
}

void AsemanNetworkSleepManager::networkTypeChanged()
{
    updateAvailablity();
}

void AsemanNetworkSleepManager::updateAvailablity()
{
    bool networkState = true;
    if(p->defaultNetwork)
    {
        networkState = (
                    p->defaultNetwork->bearerType() != AsemanNetworkManagerItem::BearerUnknown &&
                    p->defaultNetwork->bearerTypeFamily() != AsemanNetworkManagerItem::BearerUnknown &&
                    p->defaultNetwork->isValid() &&
                    p->defaultNetwork->state() == AsemanNetworkManagerItem::Active &&
                    p->defaultNetwork->type() == AsemanNetworkManagerItem::InternetAccessPoint
                );
    }

    bool hostState = p->hostCheker->available();
    setAvailable(hostState && networkState);
}

void AsemanNetworkSleepManager::setAvailable(bool stt)
{
    if(stt == p->available && !p->forceDisable)
        return;

    p->available = stt;
    emitAvailableChanged();
}

void AsemanNetworkSleepManager::emitAvailableChanged()
{
    emit availableChanged();
    if(available())
        emit wake();
    else
        emit sleep();
}

void AsemanNetworkSleepManager::startResetTimer()
{
    p->resetTimer->stop();
    p->resetTimer->start();

    bool previous = available();
    p->forceDisable = true;
    if(available() != previous)
        emitAvailableChanged();
}

void AsemanNetworkSleepManager::finishResetTimer()
{
    bool previous = available();
    p->forceDisable = false;
    if(available() != previous)
        emitAvailableChanged();
}

AsemanNetworkSleepManager::~AsemanNetworkSleepManager()
{
    delete p;
}

