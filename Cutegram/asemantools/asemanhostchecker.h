#ifndef ASEMANHOSTCHECKER_H
#define ASEMANHOSTCHECKER_H

#include <QObject>
#include <QTcpSocket>

class AsemanPingPrivate;
class AsemanHostChecker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString host     READ host     WRITE setHost     NOTIFY hostChanged)
    Q_PROPERTY(qint32  port     READ port     WRITE setPort     NOTIFY portChanged)
    Q_PROPERTY(qint32  interval READ interval WRITE setInterval NOTIFY intervalChanged)

    Q_PROPERTY(bool available READ available NOTIFY availableChanged)

public:
    AsemanHostChecker(QObject *parent = 0);
    ~AsemanHostChecker();

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
    void availableChanged();

private slots:
    void socketStateChanged(QAbstractSocket::SocketState socketState);
    void socketError(QAbstractSocket::SocketError socketError);
    void timedOut();
    void refresh();

private:
    void setAvailable(bool stt);
    void createSocket();

private:
    AsemanPingPrivate *p;
};

#endif // ASEMANHOSTCHECKER_H
