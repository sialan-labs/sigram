/*
    Copyright (C) 2014 Aseman Land
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef ASEMANDOWNLOADER_H
#define ASEMANDOWNLOADER_H

#include <QObject>
#include <QStringList>

class QNetworkReply;
class QSslError;
class AsemanDownloaderPrivate;
class AsemanDownloader : public QObject
{
    Q_PROPERTY(qint64 recievedBytes READ recievedBytes NOTIFY recievedBytesChanged)
    Q_PROPERTY(qint64 totalBytes READ totalBytes NOTIFY totalBytesChanged)
    Q_PROPERTY(QString destination READ destination WRITE setDestination NOTIFY destinationChanged)
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(int downloaderId READ downloaderId WRITE setDownloaderId NOTIFY downloaderIdChanged)

    Q_OBJECT
public:
    AsemanDownloader(QObject *parent = 0);
    ~AsemanDownloader();

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
    AsemanDownloaderPrivate *p;
};

#endif // ASEMANDOWNLOADER_H
