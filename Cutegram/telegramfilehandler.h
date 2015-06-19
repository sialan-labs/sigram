#ifndef TELEGRAMFILEHANDLER_H
#define TELEGRAMFILEHANDLER_H

#include <QObject>
#include <QUrl>
#include <QSize>

class FileLocationObject;
class UploadObject;
class DownloadObject;
class TelegramQml;
class MessageObject;
class DialogObject;
class TelegramFileHandlerPrivate;
class TelegramFileHandler : public QObject
{
    Q_OBJECT
    Q_ENUMS(ObjectType)
    Q_ENUMS(ProgressType)
    Q_ENUMS(TargetType)

    Q_PROPERTY(TelegramQml* telegram READ telegram WRITE setTelegram NOTIFY telegramChanged)
    Q_PROPERTY(QObject*     target   READ target   WRITE setTarget   NOTIFY targetChanged  )

    Q_PROPERTY(int objectType READ objectType NOTIFY objectTypeChanged)
    Q_PROPERTY(int targetType READ targetType NOTIFY targetTypeChanged)

    Q_PROPERTY(int    progressType        READ progressType        NOTIFY progressTypeChanged       )
    Q_PROPERTY(qint64 progressTotalByte   READ progressTotalByte   NOTIFY progressTotalByteChanged  )
    Q_PROPERTY(qint64 progressCurrentByte READ progressCurrentByte NOTIFY progressCurrentByteChanged)
    Q_PROPERTY(qreal  progressPercent     READ progressPercent     NOTIFY progressPercentChanged    )
    Q_PROPERTY(bool   downloaded          READ downloaded          NOTIFY downloadedChanged         )

    Q_PROPERTY(QUrl filePath  READ filePath  NOTIFY filePathChanged )
    Q_PROPERTY(QUrl thumbPath READ thumbPath NOTIFY thumbPathChanged)

    Q_PROPERTY(bool   isSticker READ isSticker NOTIFY isStickerChanged)
    Q_PROPERTY(QSize  imageSize READ imageSize NOTIFY imageSizeChanged)
    Q_PROPERTY(qint64 fileSize  READ fileSize  NOTIFY fileSizeChanged )

    Q_PROPERTY(QUrl defaultThumbnail READ defaultThumbnail WRITE setDefaultThumbnail NOTIFY defaultThumbnailChanged)

public:
    enum ObjectType {
        TypeObjectEmpty,
        TypeObjectMessage,
        TypeObjectPeer,
        TypeObjectDialog,
        TypeObjectUser,
        TypeObjectChat,
        TypeObjectFileLocation,
        TypeObjectMessageAction,
        TypeObjectMessageMedia,
        TypeObjectAudio,
        TypeObjectDocument,
        TypeObjectVideo,
        TypeObjectGeoPoint,
        TypeObjectPhoto,
        TypeObjectPhotoSizeList,
        TypeObjectPhotoSize,
        TypeObjectUserProfilePhoto,
        TypeObjectChatPhoto
    };

    enum ProgressType {
        TypeProgressEmpty,
        TypeProgressUpload,
        TypeProgressDownload
    };

    enum TargetType {
        TypeTargetUnknown,
        TypeTargetMediaPhoto,
        TypeTargetMediaAudio,
        TypeTargetMediaVideo,
        TypeTargetMediaDocument,
        TypeTargetMediaOther,
        TypeTargetChatPhoto,
        TypeTargetUserPhoto,
        TypeTargetActionChatPhoto
    };

    TelegramFileHandler(QObject *parent = 0);
    ~TelegramFileHandler();

    void setTelegram(TelegramQml *tg);
    TelegramQml *telegram() const;

    void setTarget(QObject *obj);
    QObject *target() const;

    int objectType() const;
    int targetType() const;

    int progressType() const;
    bool downloaded() const;
    qint64 progressTotalByte() const;
    qint64 progressCurrentByte() const;
    qreal progressPercent() const;

    void setDefaultThumbnail(const QUrl &url);
    QUrl defaultThumbnail() const;

    QUrl filePath() const;
    QUrl thumbPath() const;

    bool isSticker() const;
    QSize imageSize() const;
    qint64 fileSize() const;

public slots:
    bool cancelProgress();
    bool download();

signals:
    void telegramChanged();
    void targetChanged();

    void objectTypeChanged();
    void targetTypeChanged();

    void progressTypeChanged();
    void downloadedChanged();
    void progressTotalByteChanged();
    void progressCurrentByteChanged();
    void progressPercentChanged();

    void defaultThumbnailChanged();
    void filePathChanged();
    void thumbPathChanged();

    void isStickerChanged();
    void imageSizeChanged();
    void fileSizeChanged();

private slots:
    void refresh();

    void dwl_locationChanged();
    void dwl_downloadedChanged();
    void dwl_totalChanged();
    void dwl_fileIdChanged();

    void upl_locationChanged();
    void upl_uploadedChanged();
    void upl_totalSizeChanged();
    void upl_fileIdChanged();

private:
    FileLocationObject *analizeObject(QObject *target, int *targetType = 0, QObject **targetPointer = 0);
    ObjectType detectObjectType(QObject *obj);
    void detectObjectType();

    void connectLocation(FileLocationObject *lct);
    void disconnectLocation(FileLocationObject *lct);

    void connectUpload(UploadObject *ul);
    void disconnectUpload(UploadObject *ul);

private:
    TelegramFileHandlerPrivate *p;
};

#endif // TELEGRAMFILEHANDLER_H
