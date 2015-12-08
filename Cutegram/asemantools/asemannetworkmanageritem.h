#ifndef ASEMANNETWORKMANAGERITEM_H
#define ASEMANNETWORKMANAGERITEM_H

#include <QObject>
#include <QNetworkConfiguration>
#include "asemannetworkmanager.h"

class AsemanNetworkManagerItemPrivate;
class AsemanNetworkManagerItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int bearerType READ bearerType NOTIFY bearerTypeChanged)
    Q_PROPERTY(int bearerTypeFamily READ bearerTypeFamily NOTIFY bearerTypeFamilyChanged)
    Q_PROPERTY(QString bearerTypeName READ bearerTypeName NOTIFY bearerTypeNameChanged)
    Q_PROPERTY(QList<AsemanNetworkManagerItem*> children READ children NOTIFY childrenChanged)
    Q_PROPERTY(QString identifier READ identifier NOTIFY identifierChanged)
    Q_PROPERTY(bool isRoamingAvailable READ isRoamingAvailable NOTIFY isRoamingAvailableChanged)
    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(int purpose READ purpose NOTIFY purposeChanged)
    Q_PROPERTY(int state READ state NOTIFY stateChanged)
    Q_PROPERTY(int type READ type NOTIFY typeChanged)
    friend class AsemanNetworkManager;

public:
    enum Type {
        InternetAccessPoint = QNetworkConfiguration::InternetAccessPoint,
        ServiceNetwork = QNetworkConfiguration::ServiceNetwork,
        UserChoice = QNetworkConfiguration::UserChoice,
        Invalid = QNetworkConfiguration::Invalid
    };

    enum Purpose {
        UnknownPurpose = QNetworkConfiguration::UnknownPurpose,
        PublicPurpose = QNetworkConfiguration::PublicPurpose,
        PrivatePurpose = QNetworkConfiguration::PrivatePurpose,
        ServiceSpecificPurpose = QNetworkConfiguration::ServiceSpecificPurpose
    };

    enum StateFlag {
        Undefined        = QNetworkConfiguration::Undefined,
        Defined          = QNetworkConfiguration::Defined,
        Discovered       = QNetworkConfiguration::Discovered,
        Active           = QNetworkConfiguration::Active
    };

    enum BearerType {
        BearerUnknown = QNetworkConfiguration::BearerUnknown,
        BearerEthernet = QNetworkConfiguration::BearerEthernet,
        BearerWLAN = QNetworkConfiguration::BearerWLAN,
        Bearer2G = QNetworkConfiguration::Bearer2G,
        BearerCDMA2000 = QNetworkConfiguration::BearerCDMA2000,
        BearerWCDMA = QNetworkConfiguration::BearerWCDMA,
        BearerHSPA = QNetworkConfiguration::BearerHSPA,
        BearerBluetooth = QNetworkConfiguration::BearerBluetooth,
        BearerWiMAX = QNetworkConfiguration::BearerWiMAX,
        BearerEVDO = QNetworkConfiguration::BearerEVDO,
        BearerLTE = QNetworkConfiguration::BearerLTE,
        Bearer3G = QNetworkConfiguration::Bearer3G,
        Bearer4G = QNetworkConfiguration::Bearer4G
    };

    AsemanNetworkManagerItem(QObject *parent = 0);
    ~AsemanNetworkManagerItem();

    int bearerType() const;
    int bearerTypeFamily() const;
    QString bearerTypeName() const;
    QString identifier() const;
    bool isRoamingAvailable() const;
    bool isValid() const;
    QString name() const;
    int purpose() const;
    int state() const;
    int type() const;
    QList<AsemanNetworkManagerItem*> children() const;

    QObject &operator =(const QNetworkConfiguration &network);

signals:
    void bearerTypeChanged();
    void bearerTypeFamilyChanged();
    void bearerTypeNameChanged();
    void childrenChanged();
    void identifierChanged();
    void isRoamingAvailableChanged();
    void isValidChanged();
    void nameChanged();
    void purposeChanged();
    void stateChanged();
    void typeChanged();

private:
    void setChildrens(const QList<QNetworkConfiguration> &childs);
    bool childrenChanged_prv(const QList<QNetworkConfiguration> &children);
    int childIndex(const QList<QNetworkConfiguration> &childs, AsemanNetworkManagerItem *item);
    int childIndex(const QList<AsemanNetworkManagerItem*> &childs, const QNetworkConfiguration &item);
    bool isEqual(QList<QNetworkConfiguration> &a, const QList<AsemanNetworkManagerItem*> &b);

private:
    AsemanNetworkManagerItemPrivate *p;
};

#endif // ASEMANNETWORKMANAGERITEM_H
