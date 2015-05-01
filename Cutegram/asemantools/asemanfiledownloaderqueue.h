#ifndef ASEMANFILEDOWNLOADERQUEUE_H
#define ASEMANFILEDOWNLOADERQUEUE_H

#include <QObject>
#include <QUrl>

class AsemanDownloader;
class AsemanFileDownloaderQueuePrivate;
class AsemanFileDownloaderQueue : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int capacity READ capacity WRITE setCapacity NOTIFY capacityChanged)
    Q_PROPERTY(QString destination READ destination WRITE setDestination NOTIFY destinationChanged)

public:
    AsemanFileDownloaderQueue(QObject *parent = 0);
    ~AsemanFileDownloaderQueue();

    void setCapacity(int cap);
    int capacity() const;

    void setDestination(const QString &dest);
    QString destination() const;

public slots:
    void download(const QString &url, const QString &fileName);

signals:
    void capacityChanged();
    void destinationChanged();
    void finished(const QString &url, const QString &fileName);
    void progressChanged(const QString &url, const QString &fileName, qreal percent);

private slots:
    void finished( const QByteArray & data );
    void recievedBytesChanged();

private:
    void next();
    AsemanDownloader *getDownloader();

private:
    AsemanFileDownloaderQueuePrivate *p;
};

#endif // ASEMANFILEDOWNLOADERQUEUE_H
