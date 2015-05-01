#include "asemanfiledownloaderqueueitem.h"
#include "asemanfiledownloaderqueue.h"
#include "asemandevices.h"

#include <QPointer>

class AsemanFileDownloaderQueueItemPrivate
{
public:
    QPointer<AsemanFileDownloaderQueue> queue;
    QString source;
    QString result;
    QString fileName;
    qreal percent;
};

AsemanFileDownloaderQueueItem::AsemanFileDownloaderQueueItem(QObject *parent) :
    QObject(parent)
{
    p = new AsemanFileDownloaderQueueItemPrivate;
    p->percent = 0;
}

void AsemanFileDownloaderQueueItem::setSource(const QString &url)
{
    if(p->source == url)
        return;

    p->source = url;
    emit sourceChanged();

    refresh();
}

QString AsemanFileDownloaderQueueItem::source() const
{
    return p->source;
}

void AsemanFileDownloaderQueueItem::setFileName(const QString &name)
{
    if(p->fileName == name)
        return;

    p->fileName = name;
    emit fileNameChanged();

    refresh();
}

QString AsemanFileDownloaderQueueItem::fileName() const
{
    return p->fileName;
}

qreal AsemanFileDownloaderQueueItem::percent() const
{
    return p->percent;
}

void AsemanFileDownloaderQueueItem::setDownloaderQueue(AsemanFileDownloaderQueue *queue)
{
    if(p->queue == queue)
        return;

    if(p->queue)
    {
        disconnect(p->queue, SIGNAL(finished(QString,QString)), this, SLOT(finished(QString,QString)));
        disconnect(p->queue, SIGNAL(progressChanged(QString,QString,qreal)), this, SLOT(progressChanged(QString,QString,qreal)) );
    }

    p->queue = queue;
    emit downloaderQueueChanged();

    if(p->queue)
    {
        connect(p->queue, SIGNAL(finished(QString,QString)), this, SLOT(finished(QString,QString)));
        connect(p->queue, SIGNAL(progressChanged(QString,QString,qreal)), this, SLOT(progressChanged(QString,QString,qreal)) );
    }

    refresh();
}

AsemanFileDownloaderQueue *AsemanFileDownloaderQueueItem::downloaderQueue() const
{
    return p->queue;
}

QString AsemanFileDownloaderQueueItem::result() const
{
    return p->result;
}

void AsemanFileDownloaderQueueItem::finished(const QString &url, const QString &fileName)
{
    if(p->source != url || p->fileName != fileName)
        return;

    p->result = AsemanDevices::localFilesPrePath() + p->queue->destination() + "/" + fileName;
    emit resultChanged();

    p->percent = 100;
    emit percentChanged();
}

void AsemanFileDownloaderQueueItem::progressChanged(const QString &url, const QString &fileName, qreal percent)
{
    if(p->source != url || p->fileName != fileName)
        return;

    p->percent = percent;
    emit percentChanged();
}

void AsemanFileDownloaderQueueItem::refresh()
{
    if(p->source.isEmpty() || p->fileName.isEmpty())
        return;
    if(!p->queue)
        return;

    p->queue->download(p->source, p->fileName);
}

AsemanFileDownloaderQueueItem::~AsemanFileDownloaderQueueItem()
{
    delete p;
}

