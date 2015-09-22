#include "stickerfilemanager.h"
#include "asemantools/asemandevices.h"

#include <telegramqml.h>
#include <telegram.h>

#include <QList>
#include <QHash>
#include <QPointer>
#include <QDebug>
#include <QDir>
#include <QFileInfo>

class StickerFileManagerPrivate
{
public:
    QPointer<TelegramQml> telegram;
    QHash<qint64, QString> pendind_sticker_upload;
};

StickerFileManager::StickerFileManager(QObject *parent) :
    QObject(parent)
{
    p = new StickerFileManagerPrivate;
}

void StickerFileManager::setTelegram(TelegramQml *tg)
{
    if(p->telegram == tg)
        return;
    if( !tg && p->telegram )

    if(p->telegram)
        disconnect(p->telegram , SIGNAL(authLoggedInChanged()), this, SLOT(recheck()));

    p->telegram = tg;
    if(p->telegram)
        connect(p->telegram , SIGNAL(authLoggedInChanged()), this, SLOT(recheck()), Qt::QueuedConnection);

    recheck();
    emit telegramChanged();
}

TelegramQml *StickerFileManager::telegram() const
{
    return p->telegram;
}

void StickerFileManager::sendSticker(qint64 peerId, const QString &file)
{
    if(!p->telegram || !p->telegram->authLoggedIn())
        return;

    QString path = file;
    if(path.left(AsemanDevices::localFilesPrePath().size()) == AsemanDevices::localFilesPrePath())
        path = path.mid(AsemanDevices::localFilesPrePath().size());

    QStringList parts = QFileInfo(file).baseName().split("_", QString::SkipEmptyParts);
    if(parts.length() != 2)
    {
        qint64 id = p->telegram->sendFile(peerId, path);
        p->pendind_sticker_upload[id] = path;
    }
    else
    {
        InputPeer peer = p->telegram->getInputPeer(peerId);
        p->telegram->telegram()->messagesForwardDocument(peer, p->telegram->generateRandomId(),
                                                         parts.first().toLongLong(),
                                                         parts.last().toLongLong());
    }
}

void StickerFileManager::recheck()
{
    if(!p->telegram || !p->telegram->authLoggedIn())
        return;

    connect(p->telegram->telegram(), SIGNAL(messagesSendMediaAnswer(qint64,UpdatesType)),
            this, SLOT(messagesSendDocumentAnswer(qint64,UpdatesType)));
    connect(p->telegram->telegram(), SIGNAL(messagesSendDocumentAnswer(qint64,UpdatesType)),
            this, SLOT(messagesSendDocumentAnswer(qint64,UpdatesType)));
}

void StickerFileManager::messagesSendDocumentAnswer(qint64 id, const UpdatesType &updates)
{
    if(!p->pendind_sticker_upload.contains(id))
        return;

    const QString file = p->pendind_sticker_upload.take(id);


    QList<Update> updatesList = updates.updates();
    updatesList << updates.update();

    Document document;
    foreach(const Update &upd, updatesList)
    {
        const MessageMedia &media = upd.message().media();
        if(media.classType() != MessageMedia::typeMessageMediaDocument)
            continue;

        document = media.document();
    }
    if(document.classType() == Document::typeDocumentEmpty)
        return;

    const QString newName = QString("%1_%2.webp").arg(document.id()).arg(document.accessHash());
    const QString newPath = QString("%1/%2").arg(QFileInfo(file).dir().path(), newName);

    QFile::rename(file, newPath);
}

StickerFileManager::~StickerFileManager()
{
    delete p;
}

