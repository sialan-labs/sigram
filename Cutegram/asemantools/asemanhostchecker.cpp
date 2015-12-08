#include "asemanhostchecker.h"

#include <QTcpSocket>
#include <QTimer>
#include <QDebug>
#include <QDebug>

class AsemanPingPrivate
{
public:
    QString host;
    qint32 port;
    qint32 interval;
    QTcpSocket *socket;
    QTimer *timer;
    bool reconnectAfterDisconnect;
    bool available;
};

AsemanHostChecker::AsemanHostChecker(QObject *parent) :
    QObject(parent)
{
    p = new AsemanPingPrivate;
    p->port = 80;
    p->interval = 0;
    p->reconnectAfterDisconnect = false;
    p->available = false;
    p->socket = 0;

    p->timer = new QTimer(this);
    p->timer->setSingleShot(false);

    connect(p->timer, SIGNAL(timeout()), SLOT(timedOut()));
}

void AsemanHostChecker::setHost(const QString &host)
{
    if(p->host == host)
        return;

    p->host = host;
    refresh();
    emit hostChanged();
}

QString AsemanHostChecker::host() const
{
    return p->host;
}

void AsemanHostChecker::setPort(qint32 port)
{
    if(p->port == port)
        return;

    p->port = port;
    refresh();
    emit portChanged();
}

qint32 AsemanHostChecker::port() const
{
    return p->port;
}

void AsemanHostChecker::setInterval(qint32 ms)
{
    if(p->interval == ms)
        return;

    p->interval = ms;
    refresh();
    emit intervalChanged();
}

qint32 AsemanHostChecker::interval() const
{
    return p->interval;
}

bool AsemanHostChecker::available() const
{
    return p->available;
}

void AsemanHostChecker::setAvailable(bool stt)
{
    if(p->available == stt)
        return;

    p->available = stt;
    emit availableChanged();
}

void AsemanHostChecker::createSocket()
{
    if(p->socket)
    {
        disconnect(p->socket, SIGNAL(stateChanged(QAbstractSocket::SocketState)),
                   this, SLOT(socketStateChanged(QAbstractSocket::SocketState)));
        disconnect(p->socket, SIGNAL(error(QAbstractSocket::SocketError)),
                   this, SLOT(socketError(QAbstractSocket::SocketError)));
        p->socket->deleteLater();
    }

    p->socket = new QTcpSocket(this);

    connect(p->socket, SIGNAL(stateChanged(QAbstractSocket::SocketState)),
            this, SLOT(socketStateChanged(QAbstractSocket::SocketState)));
    connect(p->socket, SIGNAL(error(QAbstractSocket::SocketError)),
            this, SLOT(socketError(QAbstractSocket::SocketError)));
}

void AsemanHostChecker::refresh()
{
    p->timer->stop();
    if(p->host.isEmpty() || p->port<=0 || p->interval<=0)
        return;

    p->timer->setInterval(p->interval);
    p->timer->start();

    createSocket();
    timedOut();
}

void AsemanHostChecker::socketStateChanged(QAbstractSocket::SocketState socketState)
{
    switch(static_cast<int>(socketState))
    {
    case QAbstractSocket::UnconnectedState:
        if(p->reconnectAfterDisconnect)
        {
            p->socket->connectToHost(p->host, p->port);
            p->reconnectAfterDisconnect = false;
        }
        break;

    case QAbstractSocket::HostLookupState:
        break;

    case QAbstractSocket::ConnectingState:
        break;

    case QAbstractSocket::ConnectedState:
        setAvailable(true);
        p->socket->disconnectFromHost();
        break;

    case QAbstractSocket::BoundState:
        break;

    case QAbstractSocket::ListeningState:
        break;

    case QAbstractSocket::ClosingState:
        break;
    }
}

void AsemanHostChecker::socketError(QAbstractSocket::SocketError socketError)
{
    if(socketError != QAbstractSocket::UnknownSocketError)
    {
        setAvailable(false);
    }
}

void AsemanHostChecker::timedOut()
{
    if(p->socket->state() == QAbstractSocket::UnconnectedState)
        p->socket->connectToHost(p->host, p->port);
    else
    {
        if(p->socket->state() != QAbstractSocket::ConnectedState)
            setAvailable(false);

        p->reconnectAfterDisconnect = true;
        p->socket->disconnectFromHost();
    }
}

AsemanHostChecker::~AsemanHostChecker()
{
    delete p;
}
