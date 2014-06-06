#ifndef DOWNLOADER_H
#define DOWNLOADER_H

#include <QObject>
#include <QStringList>

class QNetworkReply;
class QSslError;
class DownloaderPrivate;
class Downloader : public QObject
{
    Q_PROPERTY(qint64 recievedBytes READ recievedBytes NOTIFY recievedBytesChanged)
    Q_PROPERTY(qint64 totalBytes READ totalBytes NOTIFY totalBytesChanged)
    Q_PROPERTY(QString destination READ destination WRITE setDestination NOTIFY destinationChanged)
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(int downloaderId READ downloaderId WRITE setDownloaderId NOTIFY downloaderIdChanged)

    Q_OBJECT
public:
    Downloader(QObject *parent = 0);
    ~Downloader();

    qint64 recievedBytes() const;
    qint64 totalBytes() const;

    void setDestination( const QString & dest );
    QString destination() const;

    void setPath( const QString & path );
    QString path() const;

    void setDownloaderId( int id );
    int downloaderId() const;

public slots:
    void start();

signals:
    void recievedBytesChanged();
    void totalBytesChanged();
    void destinationChanged();
    void downloaderIdChanged();
    void pathChanged();
    void error( const QStringList & error );
    void finished( const QByteArray & data );
    void finishedWithId( int id, const QByteArray & data );
    void failed();

private slots:
    void downloadFinished(QNetworkReply *reply);
    void sslErrors(const QList<QSslError> &list);
    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);

private:
    void init_manager();

private:
    DownloaderPrivate *p;
};

#endif // DOWNLOADER_H
