#TelegramTypeObjects

include <QString>;
include <QtQml>;
include <types/types.h>;

object FileLocation {
    qint32 localId rw = another.%name();
    qint64 secret rw = another.%name();
    qint32 dcId rw = another.%name();
    qint64 volumeId rw = another.%name();
    FileLocation::FileLocationType classType rw = another.%name();
}

object Peer {
    qint32 chatId rw = another.%name();
    qint32 userId rw = another.%name();
    Peer::PeerType classType rw = another.%name();
}

object UserStatus {
    qint32 wasOnline rw = another.%name();
    qint32 expires rw = another.%name();
    UserStatus::UserStatusType classType rw = another.%name();
}

object GeoPoint {
    double longitude rw = another.%name();
    double lat rw = another.%name();
    GeoPoint::GeoPointType classType rw = another.%name();
}

object PeerNotifySettings {
    qint32 muteUntil rw = another.%name();
    qint32 eventsMask rw = another.%name();
    QString sound rw = another.%name();
    bool showPreviews rw = false;
    PeerNotifySettings::PeerNotifySettingsType classType rw = another.%name();
}

object PhotoSize {
    qint32 h rw = another.%name();
    QString type rw = another.%name();
    QByteArray bytes rw = another.%name();
    FileLocationObject* location rw = new FileLocationObject(another.%name(), this);
    qint32 size rw = another.%name();
    qint32 w rw = another.%name();
    PhotoSize::PhotoSizeType classType rw = another.%name();
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
    Audio::AudioType classType rw = another.%name();
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
    Document::DocumentType classType rw = another.%name();
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
    Video::VideoType classType rw = another.%name();
}

object Photo {
    qint64 id rw = another.%name();
    QString caption rw = another.%name();
    qint32 date rw = another.%name();
    QList<PhotoSizeObject*> sizes rw = another.%name();
    GeoPointObject* geo rw = new GeoPointObject(another.%name(), this);
    qint64 accessHash rw = another.%name();
    qint32 userId rw = another.%name();
    Photo::PhotoType classType rw = another.%name();
}

object MessageAction {
    QString address rw = another.%name();
    qint32 userId rw = another.%name();
    PhotoObject* photo rw = new PhotoObject(another.%name(), this);
    QString title rw = another.%name();
    QList<qint32> users rw = another.%name();
    MessageAction::MessageActionType classType rw = another.%name();
}

object ChatPhoto {
    FileLocationObject* photoBig rw = new FileLocationObject(another.%name(), this);
    FileLocationObject* photoSmall rw = new FileLocationObject(another.%name(), this);
    ChatPhoto::ChatPhotoType classType rw = another.%name();
}

object UserProfilePhoto {
    qint64 photoId rw = another.%name();
    FileLocationObject* photoBig rw = new FileLocationObject(another.%name(), this);
    FileLocationObject* photoSmall rw = new FileLocationObject(another.%name(), this);
    UserProfilePhoto::UserProfilePhotoType classType rw = another.%name();
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
    bool checkedIn rw = false;
    bool left rw = false;
    Chat::ChatType classType rw = another.%name();
}

object Dialog {
    PeerObject* peer rw = new PeerObject(another.%name(), this);
    PeerNotifySettingsObject* notifySettings rw = new PeerNotifySettingsObject(another.%name(), this);
    qint32 topMessage rw = another.%name();
    qint32 unreadCount rw = another.%name();
    Dialog::DialogType classType rw = another.%name();
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
    MessageMedia::MessageMediaType classType rw = another.%name();
}

object Message {
    qint32 id rw = another.%name();
    PeerObject* toId rw = new PeerObject(another.%name(), this);
    bool unread rw = false;
    MessageActionObject* action rw = new MessageActionObject(another.%name(), this);
    qint32 fromId rw = another.%name();
    bool out rw = false;
    qint32 date rw = another.%name();
    MessageMediaObject* media rw = new MessageMediaObject(another.%name(), this);
    qint32 fwdDate rw = another.%name();
    qint32 fwdFromId rw = another.%name();
    QString message rw = another.%name();
    Message::MessageType classType rw = another.%name();
}

object User {
    qint32 id rw = another.%name();
    qint64 accessHash rw = another.%name();
    bool inactive rw = false;
    QString phone rw = another.%name();
    QString firstName rw = another.%name();
    UserProfilePhotoObject* photo rw = new UserProfilePhotoObject(another.%name(), this);
    UserStatusObject* status rw = new UserStatusObject(another.%name(), this);
    QString lastName rw = another.%name();
    User::UserType classType rw = another.%name();
}
