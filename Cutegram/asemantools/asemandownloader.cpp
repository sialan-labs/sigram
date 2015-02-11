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

#include "asemandownloader.h"

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QSslError>
#include <QFile>

class AsemanDownloaderPrivate
{
public:
    QNetworkAccessManager *manager;
    QNetworkReply *reply;

    qint64 recieved_bytes;
    qint64 total_bytes;

    QString dest;
    QString path;

    int downloader_id;
};

AsemanDownloader::AsemanDownloader(QObject *parent) :
    QObject(parent)
{
    p = new AsemanDownloaderPrivate;
    p->reply = 0;
    p->recieved_bytes = -1;
    p->total_bytes = -1;
    p->manager = 0;
    p->downloader_id = -1;
}

qint64 AsemanDownloader::recievedBytes() const
{
    return p->recieved_bytes;
}

qint64 AsemanDownloader::totalBytes() const
{
    return p->total_bytes;
}

void AsemanDownloader::setDestination(const QString &dest)
{
    if( p->dest == dest )
        return;

    p->dest = dest;
    emit destinationChanged();
}

QString AsemanDownloader::destination() const
{
    return p->dest;
}

void AsemanDownloader::setPath(const QString &path)
{
    if( p->path == path )
        return;

    p->path = path;
    emit pathChanged();
}

QString AsemanDownloader::path() const
{
    return p->path;
}

void AsemanDownloader::setDownloaderId(int id)
{
    if( p->downloader_id == id )
        return;

    p->downloader_id = id;
    emit downloaderIdChanged();
}

int AsemanDownloader::downloaderId() const
{
    return p->downloader_id;
}

void AsemanDownloader::start()
{
    if( p->path.isEmpty() )
        return;
    if( p->reply )
        return;

    init_manager();

    QNetworkRequest request = QNetworkRequest(QUrl(p->path));
    p->reply = p->manager->get(request);

    connect(p->reply, SIGNAL(sslErrors(QList<QSslError>)), SLOT(sslErrors(QList<QSslError>)));
    connect(p->reply, SIGNAL(downloadProgress(qint64,qint64)), SLOT(downloadProgress(qint64,qint64)) );
}

void AsemanDownloader::downloadFinished(QNetworkReply *reply)
{
    if( reply != p->reply )
        return;

    p->reply->deleteLater();
    p->reply = 0;
    if (reply->error())
    {
        emit error( QStringList()<<"Failed" );
        emit failed();
        return;
    }

    p->recieved_bytes = -1;
    p->total_bytes = -1;

    if( !p->dest.isEmpty() )
    {
        if( QFile::exists(p->dest) )
            QFile::remove(p->dest);

        QFile file(p->dest);
        if( !file.open(QFile::WriteOnly) )
        {
            emit error( QStringList()<<"Can't write to file." );
            emit failed();
            return;
        }

        file.write( reply->readAll() );
        file.flush();
    }

    const QByteArray & res = reply->readAll();

    emit finished( res );
    emit finishedWithId( p->downloader_id, res );
}

void AsemanDownloader::sslErrors(const QList<QSslError> &list)
{
    QStringList res;
#ifndef Q_OS_IOS
    foreach (const QSslError &error, list)
        res << error.errorString();
#endif
    emit error(res);
}

void AsemanDownloader::downloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    if( p->recieved_bytes != bytesReceived )
    {
        p->recieved_bytes = bytesReceived;
        emit recievedBytesChanged();
    }
    if( p->total_bytes != bytesTotal )
    {
        p->total_bytes = bytesTotal;
        emit totalBytesChanged();
    }
}

void AsemanDownloader::init_manager()
{
    if( p->manager )
        return;

    p->manager = new QNetworkAccessManager(this);
    connect(p->manager, SIGNAL(finished(QNetworkReply*)), SLOT(downloadFinished(QNetworkReply*)) );
}

AsemanDownloader::~AsemanDownloader()
{
    delete p;
}
