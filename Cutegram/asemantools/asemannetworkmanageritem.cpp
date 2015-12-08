#include "asemannetworkmanageritem.h"

class AsemanNetworkManagerItemPrivate
{
public:
    QNetworkConfiguration config;
    QList<AsemanNetworkManagerItem *> children;
};

AsemanNetworkManagerItem::AsemanNetworkManagerItem(QObject *parent) :
    QObject(parent)
{
    p = new AsemanNetworkManagerItemPrivate;
}

int AsemanNetworkManagerItem::bearerType() const
{
    return p->config.bearerType();
}

int AsemanNetworkManagerItem::bearerTypeFamily() const
{
    return p->config.bearerTypeFamily();
}

QString AsemanNetworkManagerItem::bearerTypeName() const
{
    return p->config.bearerTypeName();
}

QList<AsemanNetworkManagerItem *> AsemanNetworkManagerItem::children() const
{
    return p->children;
}

void AsemanNetworkManagerItem::setChildrens(const QList<QNetworkConfiguration> &childs)
{
    if(childrenChanged_prv(childs)) emit childrenChanged();
}

QString AsemanNetworkManagerItem::identifier() const
{
    return p->config.identifier();
}

bool AsemanNetworkManagerItem::isRoamingAvailable() const
{
    return p->config.isRoamingAvailable();
}

bool AsemanNetworkManagerItem::isValid() const
{
    return p->config.isValid();
}

QString AsemanNetworkManagerItem::name() const
{
    return p->config.name();
}

int AsemanNetworkManagerItem::purpose() const
{
    return p->config.purpose();
}

int AsemanNetworkManagerItem::state() const
{
    return p->config.state();
}

int AsemanNetworkManagerItem::type() const
{
    return p->config.type();
}

QObject &AsemanNetworkManagerItem::operator =(const QNetworkConfiguration &n)
{
    bool bearerTypeIsChanged = (n.bearerType() != p->config.bearerType());
    bool bearerTypeFamilyIsChanged = (n.bearerTypeFamily() != p->config.bearerTypeFamily());
    bool bearerTypeNameIsChanged = (n.bearerTypeName() != p->config.bearerTypeName());
    bool childrenIsChanged = childrenChanged_prv(n.children());
    bool identifierIsChanged = (n.identifier() != p->config.identifier());
    bool isRoamingAvailableIsChanged = (n.isRoamingAvailable() != p->config.isRoamingAvailable());
    bool isValidIsChanged = (n.isValid() != p->config.isValid());
    bool nameIsChanged = (n.name() != p->config.name());
    bool purposeIsChanged = (n.purpose() != p->config.purpose());
    bool stateIsChanged = (n.state() != p->config.state());
    bool typeIsChanged = (n.type() != p->config.type());

    p->config = n;

    if(bearerTypeIsChanged)
        emit bearerTypeChanged();
    if(bearerTypeFamilyIsChanged)
        emit bearerTypeFamilyChanged();
    if(bearerTypeNameIsChanged)
        emit bearerTypeNameChanged();
    if(childrenIsChanged)
        emit childrenChanged();
    if(identifierIsChanged)
        emit identifierChanged();
    if(isRoamingAvailableIsChanged)
        emit isRoamingAvailableChanged();
    if(isValidIsChanged)
        emit isValidChanged();
    if(nameIsChanged)
        emit nameChanged();
    if(purposeIsChanged)
        emit purposeChanged();
    if(stateIsChanged)
        emit stateChanged();
    if(typeIsChanged)
        emit typeChanged();
    return *this;
}

bool AsemanNetworkManagerItem::childrenChanged_prv(const QList<QNetworkConfiguration> &children)
{
    bool result = false;
    for( int i=0 ; i<p->children.count() ; i++ )
    {
        AsemanNetworkManagerItem *item = p->children.at(i);
        if( childIndex(children,item)!=-1 )
            continue;

        p->children.takeAt(i)->deleteLater();
        i--;
        result = true;
    }


    QList<QNetworkConfiguration> temp_list = children;
    for( int i=0 ; i<temp_list.count() ; i++ )
    {
        const QNetworkConfiguration &item = temp_list.at(i);
        if( childIndex(p->children,item)!=-1 )
            continue;

        temp_list.removeAt(i);
        i--;
    }
    while( !isEqual(temp_list,p->children) )
        for( int i=0 ; i<p->children.count() ; i++ )
        {
            AsemanNetworkManagerItem *item = p->children.at(i);
            int nw = childIndex(temp_list,item);
            if( i == nw )
                continue;

            p->children.move( i, nw );
            result = true;
        }


    for( int i=0 ; i<children.count() ; i++ )
    {
        const QNetworkConfiguration &item = children.at(i);
        if( childIndex(p->children,item)!=-1 )
            continue;

        AsemanNetworkManagerItem *newItem = new AsemanNetworkManagerItem(this);
        newItem->operator =(item);

        p->children.insert( i, newItem);
        result = true;
    }

    for(int i=0; i<p->children.count(); i++)
        p->children.at(i)->operator =(children.at(i));

    return result;
}

int AsemanNetworkManagerItem::childIndex(const QList<QNetworkConfiguration> &childs, AsemanNetworkManagerItem *item)
{
    foreach(const QNetworkConfiguration &conf, childs)
        if(conf.name() == item->name())
            return childs.indexOf(conf);
    return -1;
}

int AsemanNetworkManagerItem::childIndex(const QList<AsemanNetworkManagerItem *> &childs, const QNetworkConfiguration &item)
{
    foreach(AsemanNetworkManagerItem *conf, childs)
        if(conf->name() == item.name())
            return childs.indexOf(conf);
    return -1;
}

bool AsemanNetworkManagerItem::isEqual(QList<QNetworkConfiguration> &a, const QList<AsemanNetworkManagerItem *> &b)
{
    if(a.length() != b.length())
        return false;
    for(int i=0; i<a.length(); i++)
        if(a.at(i).identifier() != b.at(i)->identifier())
            return false;
    return true;
}

AsemanNetworkManagerItem::~AsemanNetworkManagerItem()
{
    delete p;
}
