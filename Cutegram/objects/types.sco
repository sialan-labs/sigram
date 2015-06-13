#TelegramTypeObjects

include <QString>;
include <QStringList>;
include <QtQml>;
include <QFile>;
include <types/types.h>;
include <types/decryptedmessage.h>;
include "../photosizelist.h";
include "../chatparticipantlist.h";

object Download {
    qint64 fileId rw = 0;
    QString location rw;
    qint32 mtime rw = 0;
    qint32 partId rw = 0;
    qint32 downloaded rw = 0;
    qint32 total rw = 0;
    QFile* file rw = new QFile(this);
}

object Upload {
    qint64 fileId rw = 0;
    QString location rw;
    qint32 partId rw = 0;
    qint32 uploaded rw = 0;
    qint32 totalSize rw = 0;
}

object FileLocation {
    DownloadObject* download rw = new DownloadObject(this);
    qint64 id rw = 0;
    QString fileName rw;
    QString mimeType rw;
    qint32 localId rw = another.%name();
    qint64 secret rw = another.%name();
    qint32 dcId rw = another.%name();
    qint64 accessHash rw = 0;
    qint64 volumeId rw = another.%name();
    quint32 classType rw = another.%name();
}

object Peer {
    qint32 chatId rw = another.%name();
    qint32 userId rw = another.%name();
    quint32 classType rw = another.%name();
}

object Contact {
    qint32 userId rw = another.%name();
    bool mutual rw = another.%name();
    quint32 classType rw = another.%name();
}

object InputPeer {
    qint32 chatId rw = another.%name();
    qint32 userId rw = another.%name();
    qint64 accessHash rw = another.%name();
    quint32 classType rw = another.%name();
}

object UserStatus {
    qint32 wasOnline rw = another.%name();
    qint32 expires rw = another.%name();
    quint32 classType rw = another.%name();
}

object GeoPoint {
    double longitude rw = another.%name();
    double lat rw = another.%name();
    quint32 classType rw = another.%name();
}

object PeerNotifySettings {
    qint32 muteUntil rw = another.%name();
    qint32 eventsMask rw = another.%name();
    QString sound rw = another.%name();
    bool showPreviews rw = another.%name();
    quint32 classType rw = another.%name();
}

object ContactsMyLink {
    bool contact rw = another.%name();
    quint32 classType = another.%name();
}

object EncryptedFile {
    qint32 dcId rw = another.%name();
    qint64 id rw = another.%name();
    qint32 keyFingerprint rw = another.%name();
    qint32 size rw = another.%name();
    qint64 accessHash rw = another.%name();
    quint32 classType rw = another.%name();
}

object EncryptedChat {
    qint32 id rw = another.%name();
    QByteArray gA rw = another.%name();
    qint64 keyFingerprint rw = another.%name();
    qint32 date rw = another.%name();
    qint64 accessHash rw = another.%name();
    qint32 adminId rw = another.%name();
    QByteArray gAOrB rw = another.%name();
    qint32 participantId rw = another.%name();
    quint32 classType rw = another.%name();
}

object EncryptedMessage {
    qint32 chatId rw = another.%name();
    qint32 date rw = another.%name();
    qint64 randomId rw = another.%name();
    EncryptedFileObject* file rw = new EncryptedFileObject(another.%name(), this);
    QByteArray bytes rw = another.%name();
    quint32 classType rw = another.%name();
}

object ContactLink {
    bool hasPhone rw = another.%name();
    quint32 classType rw = another.%name();
}

object NotifyPeer {
    PeerObject* peer rw = new PeerObject(another.%name(), this);
    quint32 classType rw = another.%name();
}

object ChatParticipant {
    qint32 userId rw = another.%name();
    qint32 date rw = another.%name();
    qint32 inviterId rw = another.%name();
    quint32 classType rw = another.%name();
}

object ChatParticipants {
    ChatParticipantList* participants rw = new ChatParticipantList(another.%name(), this);
    qint32 chatId rw = another.%name();
    qint32 version rw = another.%name();
    qint32 adminId rw = another.%name();
    quint32 classType rw = another.%name();
}

object PhotoSize {
    qint32 h rw = another.%name();
    QString type rw = another.%name();
    QByteArray bytes rw = another.%name();
    FileLocationObject* location rw = new FileLocationObject(another.%name(), this);
    qint32 size rw = another.%name();
    qint32 w rw = another.%name();
    quint32 classType rw = another.%name();
}

object Audio {
    qint64 id rw = another.%name();
    qint32 dcId rw = another.%name();
    QString mimeType rw = another.%name();
    qint32 duration rw = another.%name();
    qint32 date rw = another.%name();
    qint32 size rw = another.%name();
    qint64 accessHash rw = another.%name();
    qint32 userId rw = another.%name();
    quint32 classType rw = another.%name();
}

object Document {
    qint64 id rw = another.%name();
    qint32 dcId rw = another.%name();
    QString mimeType rw = another.%name();
    PhotoSizeObject* thumb rw = new PhotoSizeObject(another.%name(), this);
    qint32 date rw = another.%name();
    QString fileName rw = another.%name();
    qint64 accessHash rw = another.%name();
    qint32 userId rw = another.%name();
    qint32 size rw = another.%name();
    QByteArray encryptKey rw = QByteArray();
    QByteArray encryptIv rw = QByteArray();
    quint32 classType rw = another.%name();
}

object Video {
    qint64 id rw = another.%name();
    qint32 dcId rw = another.%name();
    QString caption rw = another.%name();
    QString mimeType rw = another.%name();
    qint32 date rw = another.%name();
    PhotoSizeObject* thumb rw = new PhotoSizeObject(another.%name(), this);
    qint32 duration rw = another.%name();
    qint32 h rw = another.%name();
    qint32 size rw = another.%name();
    qint64 accessHash rw = another.%name();
    qint32 userId rw = another.%name();
    qint32 w rw = another.%name();
    quint32 classType rw = another.%name();
}

object Photo {
    qint64 id rw = another.%name();
    QString caption rw = another.%name();
    qint32 date rw = another.%name();
    PhotoSizeList* sizes rw = new PhotoSizeList(another.%name(), this);
    GeoPointObject* geo rw = new GeoPointObject(another.%name(), this);
    qint64 accessHash rw = another.%name();
    qint32 userId rw = another.%name();
    quint32 classType rw = another.%name();
}

object WallPaper {
    qint32 bgColor rw = another.%name();
    qint32 color rw = another.%name();
    qint32 id rw = another.%name();
    QString title rw = another.%name();
    PhotoSizeList* sizes rw = new PhotoSizeList(another.%name(), this);
    quint32 classType rw = another.%name();
}

object MessageAction {
    QString address rw = another.%name();
    qint32 userId rw = another.%name();
    PhotoObject* photo rw = new PhotoObject(another.%name(), this);
    QString title rw = another.%name();
    QList<qint32> users rw = another.%name();
    quint32 classType rw = another.%name();
}

object ChatPhoto {
    FileLocationObject* photoBig rw = new FileLocationObject(another.%name(), this);
    FileLocationObject* photoSmall rw = new FileLocationObject(another.%name(), this);
    quint32 classType rw = another.%name();
}

object ChatFull {
    ChatParticipantsObject* participants rw = new ChatParticipantsObject(another.%name(), this);
    PhotoObject* chatPhoto rw = new PhotoObject(another.%name(), this);
    qint32 id rw = another.%name();
    PeerNotifySettingsObject* notifySettings rw = new PeerNotifySettingsObject(another.%name(), this);
    quint32 classType rw = another.%name();
}

object UserProfilePhoto {
    qint64 photoId rw = another.%name();
    FileLocationObject* photoBig rw = new FileLocationObject(another.%name(), this);
    FileLocationObject* photoSmall rw = new FileLocationObject(another.%name(), this);
    quint32 classType rw = another.%name();
}

object Chat {
    qint32 participantsCount rw = another.%name();
    qint32 id rw = another.%name();
    qint32 version rw = another.%name();
    QString venue rw = another.%name();
    QString title rw = another.%name();
    QString address rw = another.%name();
    qint32 date rw = another.%name();
    ChatPhotoObject* photo rw = new ChatPhotoObject(another.%name(), this);
    GeoPointObject* geo rw = new GeoPointObject(another.%name(), this);
    qint64 accessHash rw = another.%name();
    bool checkedIn rw = another.%name();
    bool left rw = another.%name();
    quint32 classType rw = another.%name();
}

object Dialog {
    PeerObject* peer rw = new PeerObject(another.%name(), this);
    PeerNotifySettingsObject* notifySettings rw = new PeerNotifySettingsObject(another.%name(), this);
    qint32 topMessage rw = another.%name();
    qint32 unreadCount rw = another.%name();
    bool encrypted rw = false;
    QStringList typingUsers rw;
    quint32 classType rw = another.%name();
}

object SendMessageAction {
    quint32 classType rw = another.%name();
}

object DecryptedMessageAction {
    qint32 layer rw = another.%name();
    QList<qint64> randomIds rw = another.%name();
    qint32 ttlSeconds rw = another.%name();
    qint32 startSeqNo rw = another.%name();
    qint32 endSeqNo rw = another.%name();
    SendMessageActionObject* action rw = new SendMessageActionObject(another.%name(), this);
    quint32 classType rw = another.%name();
}

object DecryptedMessageMedia {
    QByteArray thumb rw = another.%name();
    qint32 thumbW rw = another.%name();
    qint32 thumbH rw = another.%name();
    qint32 duration rw = another.%name();
    qint32 w rw = another.%name();
    qint32 h rw = another.%name();
    qint32 size rw = another.%name();
    double latitude rw = another.%name();
    double longitude rw = another.%name();
    QByteArray key rw = another.%name();
    QByteArray iv rw = another.%name();
    QString phoneNumber rw = another.%name();
    QString firstName rw = another.%name();
    QString lastName rw = another.%name();
    qint32 userId rw = another.%name();
    QString fileName rw = another.%name();
    QString mimeType rw = another.%name();
    quint32 classType rw = another.%name();
}

object DecryptedMessage {
    qint64 randomId rw = another.%name();
    qint32 ttl rw = another.%name();
    QByteArray randomBytes rw = another.%name();
    QString message rw = another.%name();
    DecryptedMessageMediaObject* media rw = new DecryptedMessageMediaObject(another.%name(), this);
    DecryptedMessageActionObject* action rw = new DecryptedMessageActionObject(another.%name(), this);
    quint32 classType rw = another.%name();
}

object MessageMedia {
    AudioObject* audio rw = new AudioObject(another.%name(), this);
    QString lastName rw = another.%name();
    QByteArray bytes rw = another.%name();
    QString firstName rw = another.%name();
    DocumentObject* document rw = new DocumentObject(another.%name(), this);
    GeoPointObject* geo rw = new GeoPointObject(another.%name(), this);
    PhotoObject* photo rw = new PhotoObject(another.%name(), this);
    QString phoneNumber rw = another.%name();
    qint32 userId rw = another.%name();
    VideoObject* video rw = new VideoObject(another.%name(), this);
    quint32 classType rw = another.%name();
}

object Message {
    qint32 id rw = another.%name();
    bool sent rw = true;
    bool encrypted rw = false;
    UploadObject* upload rw = new UploadObject(this);
    PeerObject* toId rw = new PeerObject(another.%name(), this);
    bool unread rw = another.%name();
    MessageActionObject* action rw = new MessageActionObject(another.%name(), this);
    qint32 fromId rw = another.%name();
    bool out rw = another.%name();
    qint32 date rw = another.%name();
    MessageMediaObject* media rw = new MessageMediaObject(another.%name(), this);
    qint32 fwdDate rw = another.%name();
    qint32 fwdFromId rw = another.%name();
    QString message rw = another.%name();
    quint32 classType rw = another.%name();
}

object GeoChatMessage {
    qint32 id rw = another.%name();
    MessageActionObject* action rw = new MessageActionObject(another.%name(), this);
    qint32 fromId rw = another.%name();
    qint32 date rw = another.%name();
    MessageMediaObject* media rw = new MessageMediaObject(another.%name(), this);
    qint32 chatId rw = another.%name();
    QString message rw = another.%name();
    quint32 classType rw = another.%name();
}

object User {
    qint32 id rw = another.%name();
    qint64 accessHash rw = another.%name();
    bool inactive rw = another.%name();
    QString phone rw = another.%name();
    QString firstName rw = another.%name();
    UserProfilePhotoObject* photo rw = new UserProfilePhotoObject(another.%name(), this);
    UserStatusObject* status rw = new UserStatusObject(another.%name(), this);
    QString lastName rw = another.%name();
    QString username rw = another.%name();
    quint32 classType rw = another.%name();
}
