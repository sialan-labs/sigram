#ifndef ASEMANFILEDOWNLOADERQUEUEITEM_H
#define ASEMANFILEDOWNLOADERQUEUEITEM_H

#include <QObject>

class AsemanFileDownloaderQueue;
class AsemanFileDownloaderQueueItemPrivate;
class AsemanFileDownloaderQueueItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString fileName READ fileName WRITE setFileName NOTIFY fileNameChanged)
    Q_PROPERTY(qreal percent READ percent NOTIFY percentChanged)
    Q_PROPERTY(AsemanFileDownloaderQueue* downloaderQueue READ downloaderQueue WRITE setDownloaderQueue NOTIFY downloaderQueueChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)

public:
    AsemanFileDownloaderQueueItem(QObject *parent = 0);
    ~AsemanFileDownloaderQueueItem();

    void setSource(const QString &url);
    QString source() const;

    void setFileName(const QString &name);
    QString fileName() const;

    qreal percent() const;

    void setDownloaderQueue(AsemanFileDownloaderQueue *queue);
    AsemanFileDownloaderQueue *downloaderQueue() const;

    QString result() const;

signals:
    void sourceChanged();
    void downloaderQueueChanged();
    void resultChanged();
    void fileNameChanged();
    void percentChanged();

private slots:
    void finished(const QString &url, const QString &fileName);
    void progressChanged(const QString &url, const QString &fileName, qreal percent);

private:
    void refresh();

private:
    AsemanFileDownloaderQueueItemPrivate *p;
};

#endif // ASEMANFILEDOWNLOADERQUEUEITEM_H
