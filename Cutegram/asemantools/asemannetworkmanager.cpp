#include "asemannetworkmanager.h"
#include "asemannetworkmanageritem.h"

#include <QNetworkConfigurationManager>
#include <QDebug>
#include <QNetworkAccessManager>
#include <QTimer>
#include <QMap>
#include <QPointer>

class AsemanNetworkCheckerPrivate
{
public:
    QPointer<AsemanNetworkManagerItem> defaultItem;
    QVariantMap map;
    QNetworkConfigurationManager *network;
    QNetworkConfiguration lastConfig;

    QTimer *updateTimer;
};

AsemanNetworkManager::AsemanNetworkManager(QObject *parent) :
    QObject(parent)
{
    p = new AsemanNetworkCheckerPrivate;
    p->network = new QNetworkConfigurationManager(this);
    p->defaultItem = new AsemanNetworkManagerItem(this);

    p->updateTimer = new QTimer(this);
    p->updateTimer->setInterval(1000);
    p->updateTimer->start();

    p->lastConfig = p->network->defaultConfiguration();

    connect(p->network, SIGNAL(configurationAdded(QNetworkConfiguration)),
            SLOT(configureAdded(QNetworkConfiguration)));
    connect(p->network, SIGNAL(configurationChanged(QNetworkConfiguration)),
            this, SLOT(configureChanged(QNetworkConfiguration)));
    connect(p->network, SIGNAL(configurationRemoved(QNetworkConfiguration)),
            SLOT(configureRemoved(QNetworkConfiguration)));

    connect(p->network, SIGNAL(updateCompleted()), SLOT(updateCheck()));
    connect(p->updateTimer, SIGNAL(timeout()), SLOT(updateCheck()));

    foreach(const QNetworkConfiguration &config, p->network->allConfigurations())
        configureAdded(config);

    updateCheck();
}

QString AsemanNetworkManager::defaultNetworkIdentifier() const
{
    return p->lastConfig.identifier();
}

AsemanNetworkManagerItem *AsemanNetworkManager::defaultNetwork() const
{
    return p->defaultItem;
}

QVariantMap AsemanNetworkManager::configurations() const
{
    return p->map;
}

void AsemanNetworkManager::setInterval(qint32 ms)
{
    if(p->updateTimer->interval() == ms)
        return;

    p->updateTimer->setInterval(ms);
    p->updateTimer->stop();
    p->updateTimer->start();

    emit intervalChanged();
}

qint32 AsemanNetworkManager::interval() const
{
    return p->updateTimer->interval();
}

void AsemanNetworkManager::configureChanged(const QNetworkConfiguration &config)
{
    AsemanNetworkManagerItem *item = p->map.value(config.identifier()).value<AsemanNetworkManagerItem*>();
    if(item)
        item->operator =(config);
}

void AsemanNetworkManager::configureAdded(const QNetworkConfiguration &config)
{
    AsemanNetworkManagerItem *item = new AsemanNetworkManagerItem(this);
    item->operator =(config);
    p->map[config.identifier()] = QVariant::fromValue<AsemanNetworkManagerItem*>(item);

    emit configurationsChanged();
}

void AsemanNetworkManager::configureRemoved(const QNetworkConfiguration &config)
{
    AsemanNetworkManagerItem *item = p->map.take(config.identifier()).value<AsemanNetworkManagerItem*>();
    if(item)
        item->deleteLater();

    emit configurationsChanged();
}

void AsemanNetworkManager::updateCheck()
{
    p->defaultItem->operator =(p->network->defaultConfiguration());

    if(p->lastConfig.identifier() == p->network->defaultConfiguration().identifier())
    {
        p->lastConfig = p->network->defaultConfiguration();
        return;
    }

    p->lastConfig = p->network->defaultConfiguration();
    emit defaultNetworkIdentifierChanged();
}

AsemanNetworkManager::~AsemanNetworkManager()
{
    delete p;
}

