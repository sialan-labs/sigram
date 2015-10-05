#ifndef STICKERFILEMANAGER_H
#define STICKERFILEMANAGER_H

#include <QObject>

class TelegramQml;
class StickerFileManagerPrivate;
class StickerFileManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(TelegramQml* telegram READ telegram WRITE setTelegram NOTIFY telegramChanged)

public:
    StickerFileManager(QObject *parent = 0);
    ~StickerFileManager();

    void setTelegram(TelegramQml *tg);
    TelegramQml *telegram() const;

public slots:
    void sendSticker(qint64 peerId, const QString &file);

signals:
    void telegramChanged();

private slots:
    void recheck();
    void messagesSendDocumentAnswer(qint64 id, const class UpdatesType &updates);

private:
    StickerFileManagerPrivate *p;
};

#endif // STICKERFILEMANAGER_H
