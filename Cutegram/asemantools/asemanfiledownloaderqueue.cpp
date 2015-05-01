#include "asemanfiledownloaderqueue.h"
#include "asemandownloader.h"

#include <QQueue>
#include <QStack>
#include <QSet>
#include <QFile>
#include <QFileInfo>
#include <QDir>

class AsemanFileDownloaderQueuePrivate
{
public:
    QStack<AsemanDownloader*> inactiveItems;
    QSet<AsemanDownloader*> activeItems;
    QQueue<QString> queue;
    QHash<QString, QSet<QString> > names;

    int capacity;
    QString destination;
};

AsemanFileDownloaderQueue::AsemanFileDownloaderQueue(QObject *parent) :
    QObject(parent)
{
    p = new AsemanFileDownloaderQueuePrivate;
    p->capacity = 2;
}

void AsemanFileDownloaderQueue::setCapacity(int cap)
{
    if(p->capacity == cap)
        return;

    p->capacity = cap;
    emit capacityChanged();
}

int AsemanFileDownloaderQueue::capacity() const
{
    return p->capacity;
}

void AsemanFileDownloaderQueue::setDestination(const QString &dest)
{
    if(p->destination == dest)
        return;

    p->destination = dest;
    QDir().mkpath(p->destination);

    emit destinationChanged();
}

QString AsemanFileDownloaderQueue::destination() const
{
    return p->destination;
}

void AsemanFileDownloaderQueue::download(const QString &url, const QString &fileName)
{
    if( QFileInfo(p->destination+"/"+fileName).exists() )
    {
        emit progressChanged(url, fileName, 100);
        emit finished(url, fileName);
        return;
    }

    p->names[url].insert(fileName);
    if(p->queue.contains(url))
        return;

    p->queue.append(url);
    next();
}

void AsemanFileDownloaderQueue::finished(const QByteArray &data)
{
    AsemanDownloader *downloader = static_cast<AsemanDownloader*>(sender());
    if(!downloader)
        return;

    const QString &url = downloader->path();
    const QSet<QString> names = p->names.value(url);
    foreach(const QString &name, names)
    {
        QFile file(p->destination + "/" + name);
        if(!file.open(QFile::WriteOnly))
            continue;

        file.write(data);
        file.close();
        emit finished(url, name);
    }

    p->names.remove(url);
    p->activeItems.remove(downloader);
    p->inactiveItems.push(downloader);
    next();
}

void AsemanFileDownloaderQueue::recievedBytesChanged()
{
    AsemanDownloader *downloader = static_cast<AsemanDownloader*>(sender());
    if(!downloader)
        return;

    const qint64 total = downloader->totalBytes();
    const qint64 recieved = downloader->recievedBytes();
    const qreal percent = ((qreal)recieved/total)*100;
    const QString &url = downloader->path();
    const QSet<QString> names = p->names.value(url);
    foreach(const QString &name, names)
        emit progressChanged(url, name, percent);
}

void AsemanFileDownloaderQueue::next()
{
    while(!p->inactiveItems.isEmpty() && p->inactiveItems.count()+p->activeItems.count()>p->capacity)
        p->inactiveItems.pop()->deleteLater();
    if(p->queue.isEmpty())
        return;

    AsemanDownloader *downloader = getDownloader();
    if(!downloader)
        return;

    const QString &url = p->queue.takeFirst();
    downloader->setPath(url);
    downloader->start();
}

AsemanDownloader *AsemanFileDownloaderQueue::getDownloader()
{
    if(!p->inactiveItems.isEmpty())
        return p->inactiveItems.pop();
    if(p->activeItems.count() >= p->capacity)
        return 0;

    AsemanDownloader *result = new AsemanDownloader(this);
    p->activeItems.insert(result);

    connect(result, SIGNAL(recievedBytesChanged()), SLOT(recievedBytesChanged()));
    connect(result, SIGNAL(finished(QByteArray)), SLOT(finished(QByteArray)));

    return result;
}

AsemanFileDownloaderQueue::~AsemanFileDownloaderQueue()
{
    delete p;
}

