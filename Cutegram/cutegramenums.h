#ifndef CUTEGRAMENUMS_H
#define CUTEGRAMENUMS_H

#include <QObject>
#include <QNetworkProxy>

class CutegramEnums : public QObject
{
    Q_OBJECT
    Q_ENUMS(ProxyTypes)

public:
    enum ProxyTypes {
        ProxyNoProxy = QNetworkProxy::NoProxy,
        ProxyHttpProxy = QNetworkProxy::HttpProxy,
        ProxySocks5Proxy = QNetworkProxy::Socks5Proxy
    };

    CutegramEnums(QObject *parent = 0);
    ~CutegramEnums();
};

#endif // CUTEGRAMENUMS_H
