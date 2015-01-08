#include "databasecore.h"
#include "cutegram_macros.h"

#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QList>
#include <QDebug>
#include <QTimerEvent>

class DatabaseCorePrivate
{
public:
    QSqlDatabase db;
    QString path;

    int commit_timer;
};

DatabaseCore::DatabaseCore(const QString &path, const QString &phoneNumber, QObject *parent) :
    QObject(parent)
{
    p = new DatabaseCorePrivate;
    p->path = path;
    p->commit_timer = 0;

    p->db = QSqlDatabase::addDatabase("QSQLITE",DATABASE_DB_CONNECTION+phoneNumber);
    p->db.setDatabaseName(p->path);

    reconnect();

    qRegisterMetaType<DbUser>("DbUser");
    qRegisterMetaType<DbChat>("DbChat");
    qRegisterMetaType<DbDialog>("DbDialog");
    qRegisterMetaType<DbMessage>("DbMessage");
    qRegisterMetaType<DbPeer>("DbPeer");
}

void DatabaseCore::disconnect()
{
    p->db.close();
}

void DatabaseCore::insertUser(const DbUser &duser)
{
    begin();
    const User &user = duser.user;
    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO Users (id, accessHash, inactive, phone, firstName, lastName, username, type, photoId, photoBigLocalId, photoBigSecret, photoBigDcId, photoBigVolumeId, photoSmallLocalId, photoSmallSecret, photoSmallDcId, photoSmallVolumeId, statusWasOnline, statusExpires, statusType) "
                  "VALUES (:id, :accessHash, :inactive, :phone, :firstName, :lastName, :username, :type, :photoId, :photoBigLocalId, :photoBigSecret, :photoBigDcId, :photoBigVolumeId, :photoSmallLocalId, :photoSmallSecret, :photoSmallDcId, :photoSmallVolumeId, :statusWasOnline, :statusExpires, :statusType);");

    query.bindValue(":id",user.id() );
    query.bindValue(":accessHash",user.accessHash() );
    query.bindValue(":inactive",user.inactive() );
    query.bindValue(":phone",user.phone() );
    query.bindValue(":firstName",user.firstName() );
    query.bindValue(":lastName",user.lastName() );
    query.bindValue(":username",user.username() );
    query.bindValue(":type",user.classType() );

    const UserProfilePhoto &photo = user.photo();
    query.bindValue(":photoId",photo.photoId() );

    const FileLocation &photoBig = photo.photoBig();
    query.bindValue(":photoBigLocalId",photoBig.localId() );
    query.bindValue(":photoBigSecret",photoBig.secret() );
    query.bindValue(":photoBigDcId",photoBig.dcId() );
    query.bindValue(":photoBigVolumeId",photoBig.volumeId() );

    const FileLocation &photoSmall = photo.photoSmall();
    query.bindValue(":photoSmallLocalId",photoSmall.localId() );
    query.bindValue(":photoSmallSecret",photoSmall.secret() );
    query.bindValue(":photoSmallDcId",photoSmall.dcId() );
    query.bindValue(":photoSmallVolumeId",photoSmall.volumeId() );

    const UserStatus &status = user.status();
    query.bindValue(":statusWasOnline",status.wasOnline() );
    query.bindValue(":statusExpires",status.expires() );
    query.bindValue(":statusType",status.classType() );

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }
}

void DatabaseCore::insertChat(const DbChat &dchat)
{
    begin();
    const Chat &chat = dchat.chat;
    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO Chats (id, participantsCount, version, venue, title, address, date, geo, accessHash, checkedIn, left, type, photoId, photoBigLocalId, photoBigSecret, photoBigDcId, photoBigVolumeId, photoSmallLocalId, photoSmallSecret, photoSmallDcId, photoSmallVolumeId) "
                  "VALUES (:id, :participantsCount, :version, :venue, :title, :address, :date, :geo, :accessHash, :checkedIn, :left, :type, :photoId, :photoBigLocalId, :photoBigSecret, :photoBigDcId, :photoBigVolumeId, :photoSmallLocalId, :photoSmallSecret, :photoSmallDcId, :photoSmallVolumeId);");

    query.bindValue(":id",chat.id() );
    query.bindValue(":accessHash",chat.accessHash() );
    query.bindValue(":participantsCount",chat.participantsCount() );
    query.bindValue(":version",chat.version() );
    query.bindValue(":venue",chat.venue() );
    query.bindValue(":title",chat.title() );
    query.bindValue(":address",chat.address() );
    query.bindValue(":address",chat.address() );
    query.bindValue(":date",chat.date() );
    query.bindValue(":geo",0 );
    query.bindValue(":checkedIn",chat.checkedIn() );
    query.bindValue(":left",chat.left() );
    query.bindValue(":type",chat.classType() );

    const ChatPhoto &photo = chat.photo();
    query.bindValue(":photoId",photo.classType()==ChatPhoto::typeChatPhotoEmpty?0:1);

    const FileLocation &photoBig = photo.photoBig();
    query.bindValue(":photoBigLocalId",photoBig.localId() );
    query.bindValue(":photoBigSecret",photoBig.secret() );
    query.bindValue(":photoBigDcId",photoBig.dcId() );
    query.bindValue(":photoBigVolumeId",photoBig.volumeId() );

    const FileLocation &photoSmall = photo.photoSmall();
    query.bindValue(":photoSmallLocalId",photoSmall.localId() );
    query.bindValue(":photoSmallSecret",photoSmall.secret() );
    query.bindValue(":photoSmallDcId",photoSmall.dcId() );
    query.bindValue(":photoSmallVolumeId",photoSmall.volumeId() );

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }
}

void DatabaseCore::insertDialog(const DbDialog &ddialog)
{
    begin();
    const Dialog &dialog = ddialog.dialog;
    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO Dialogs (peer, peerType, topMessage, unreadCount) "
                  "VALUES (:peer, :peerType, :topMessage, :unreadCount);");

    query.bindValue(":peer",dialog.peer().classType()==Peer::typePeerChat?dialog.peer().chatId():dialog.peer().userId() );
    query.bindValue(":peerType",dialog.peer().classType() );
    query.bindValue(":topMessage",dialog.topMessage() );
    query.bindValue(":unreadCount",dialog.unreadCount() );

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }
}

void DatabaseCore::insertMessage(const DbMessage &dmessage)
{
    begin();
    const Message &message = dmessage.message;
    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO Messages (id, toId, toPeerType, unread, fromId, out, date, fwdDate, fwdFromId, message, actionAddress, actionUserId, actionPhoto, actionTitle, actionUsers, actionType, mediaAudio, mediaLastName, mediaFirstName, mediaPhoneNumber, mediaDocument, mediaGeo, mediaPhoto, mediaUserId, mediaVideo, mediaType) "
                  "VALUES (:id, :toId, :toPeerType, :unread, :fromId, :out, :date, :fwdDate, :fwdFromId, :message, :actionAddress, :actionUserId, :actionPhoto, :actionTitle, :actionUsers, :actionType, :mediaAudio, :mediaLastName, :mediaFirstName, :mediaPhoneNumber, :mediaDocument, :mediaGeo, :mediaPhoto, :mediaUserId, :mediaVideo, :mediaType);");

    query.bindValue(":id",message.id() );
    query.bindValue(":toId",message.toId().classType()==Peer::typePeerChat?message.toId().chatId():message.toId().userId() );
    query.bindValue(":toPeerType",message.toId().classType() );
    query.bindValue(":unread",message.unread() );
    query.bindValue(":fromId",message.fromId() );
    query.bindValue(":out",message.out() );
    query.bindValue(":date",message.date() );
    query.bindValue(":fwdDate",message.fwdDate() );
    query.bindValue(":fwdFromId",message.fwdFromId() );
    query.bindValue(":message",message.message() );

    const MessageAction &action = message.action();
    query.bindValue(":actionAddress",action.address() );
    query.bindValue(":actionUserId",action.userId() );
    query.bindValue(":actionPhoto",action.photo().id() );
    query.bindValue(":actionTitle",action.title() );
    query.bindValue(":actionUsers", usersToString(action.users()) );
    query.bindValue(":actionType",action.classType() );

    const MessageMedia &media = message.media();
    query.bindValue(":mediaLastName",media.lastName() );
    query.bindValue(":mediaFirstName",media.firstName() );
    query.bindValue(":mediaPhoneNumber",media.phoneNumber() );
    query.bindValue(":mediaUserId",media.userId() );
    query.bindValue(":mediaType",media.classType() );

    query.bindValue(":mediaDocument",media.document().id() );
    query.bindValue(":mediaGeo",message.id() );
    query.bindValue(":mediaPhoto",media.photo().id() );
    query.bindValue(":mediaVideo",media.video().id() );
    query.bindValue(":mediaAudio",media.audio().id() );

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }

    insertAudio(media.audio());
    insertDocument(media.document());
    insertGeo(message.id(), media.geo());
    insertPhoto(media.photo());
    insertVideo(media.video());
}

void DatabaseCore::readFullDialogs()
{
    readUsers();
    readChats();
    readDialogs();
}

void DatabaseCore::readMessages(const DbPeer &dpeer, int offset, int limit)
{
    const Peer & peer = dpeer.peer;
    QSqlQuery query(p->db);
    if( peer.classType() == Peer::typePeerChat )
        query.prepare("SELECT * FROM Messages WHERE toId=:chatId AND toPeerType=:toPeerType ORDER BY id DESC LIMIT :limit OFFSET :offset");
    else
        query.prepare("SELECT * FROM Messages WHERE toPeerType=:toPeerType AND "
                      "( (toId=:userId AND out=1) OR (fromId=:userId AND out=0) ) ORDER BY id DESC LIMIT :limit OFFSET :offset");

    query.bindValue(":userId", peer.userId());
    query.bindValue(":chatId", peer.chatId());
    query.bindValue(":toPeerType", peer.classType());
    query.bindValue(":offset", offset);
    query.bindValue(":limit", limit);

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }

    while(query.next())
    {
        const QSqlRecord &record = query.record();

        MessageAction action( static_cast<MessageAction::MessageActionType>(record.value("actionType").toLongLong()) );
        action.setAddress( record.value("actionAddress").toString() );
        action.setUserId( record.value("actionUserId").toLongLong() );
        action.setTitle( record.value("actionTitle").toString() );
        action.setUsers( stringToUsers(record.value("actionUsers").toString()) );
        action.setPhoto( readPhoto(record.value("actionPhoto").toLongLong()) );

        MessageMedia media( static_cast<MessageMedia::MessageMediaType>(record.value("mediaType").toLongLong()) );
        media.setFirstName( record.value("mediaFirstName").toString() );
        media.setLastName( record.value("mediaLastName").toString() );
        media.setPhoneNumber( record.value("mediaPhoneNumber").toString() );
        media.setUserId( record.value("mediaUserId").toLongLong() );
        media.setAudio( readAudio(record.value("mediaAudio").toLongLong()) );
        media.setVideo( readVideo(record.value("mediaVideo").toLongLong()) );
        media.setDocument( readDocument(record.value("mediaDocument").toLongLong()) );
        media.setPhoto( readPhoto(record.value("mediaPhoto").toLongLong()) );
        media.setGeo( readGeo(record.value("mediaGeo").toLongLong()) );

        Peer toPeer( static_cast<Peer::PeerType>(record.value("toPeerType").toLongLong()) );
        if(toPeer.classType() == Peer::typePeerChat)
            toPeer.setChatId(record.value("toId").toLongLong());
        else
            toPeer.setUserId(record.value("toId").toLongLong());

        Message message;
        message.setToId(toPeer);
        message.setAction(action);
        message.setId( record.value("id").toLongLong() );
        message.setUnread( record.value("unread").toBool() );
        message.setFromId( record.value("fromId").toLongLong() );
        message.setOut( record.value("out").toBool() );
        message.setDate( record.value("date").toLongLong() );
        message.setFwdDate( record.value("fwdDate").toLongLong() );
        message.setFwdFromId( record.value("fwdFromId").toLongLong() );
        message.setMessage( record.value("message").toString() );

        DbMessage dmsg;
        dmsg.message = message;

        emit messageFounded(dmsg);
    }
}

void DatabaseCore::deleteMessage(qint64 msgId)
{
    QSqlQuery query( p->db );
    query.prepare("DELETE FROM Messages WHERE id=:id" );
    query.bindValue( ":id" , msgId );
    query.exec();
}

void DatabaseCore::deleteDialog(qint64 dlgId)
{
    QSqlQuery query( p->db );
    query.prepare("DELETE FROM Dialogs WHERE peer=:peer" );
    query.bindValue( ":peer" , dlgId );
    query.exec();
}

void DatabaseCore::readDialogs()
{
    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM Dialogs");

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }

    while(query.next())
    {
        const QSqlRecord &record = query.record();

        Peer peer( static_cast<Peer::PeerType>(record.value("peerType").toLongLong()) );
        if(peer.classType() == Peer::typePeerChat)
            peer.setChatId(record.value("peer").toLongLong());
        else
            peer.setUserId(record.value("peer").toLongLong());

        Dialog dialog;
        dialog.setPeer(peer);
        dialog.setTopMessage( record.value("topMessage").toLongLong() );
        dialog.setUnreadCount( record.value("unreadCount").toLongLong() );

        DbDialog ddlg;
        ddlg.dialog = dialog;

        emit dialogFounded(ddlg);
    }
}

void DatabaseCore::readUsers()
{
    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM Users");

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }

    while(query.next())
    {
        const QSqlRecord &record = query.record();

        UserStatus status( static_cast<UserStatus::UserStatusType>(record.value("statusType").toLongLong()) );
        status.setWasOnline( record.value("statusWasOnline").toLongLong() );
        status.setExpires( record.value("statusExpires").toLongLong() );

        UserProfilePhoto photo(UserProfilePhoto::typeUserProfilePhotoEmpty);
        photo.setPhotoId( record.value("photoId").toLongLong() );
        if(photo.photoId() != 0)
        {
            FileLocation bigPhoto(FileLocation::typeFileLocation);
            bigPhoto.setLocalId( record.value("photoBigLocalId").toLongLong() );
            bigPhoto.setSecret( record.value("photoBigSecret").toLongLong() );
            bigPhoto.setDcId( record.value("photoBigDcId").toLongLong() );
            bigPhoto.setVolumeId( record.value("photoBigVolumeId").toLongLong() );

            FileLocation smallPhoto(FileLocation::typeFileLocation);
            smallPhoto.setLocalId( record.value("photoSmallLocalId").toLongLong() );
            smallPhoto.setSecret( record.value("photoSmallSecret").toLongLong() );
            smallPhoto.setDcId( record.value("photoSmallDcId").toLongLong() );
            smallPhoto.setVolumeId( record.value("photoSmallVolumeId").toLongLong() );

            photo.setClassType(UserProfilePhoto::typeUserProfilePhoto);
            photo.setPhotoBig(bigPhoto);
            photo.setPhotoSmall(smallPhoto);
        }

        User user(User::typeUserEmpty);
        user.setId( record.value("id").toLongLong() );
        user.setAccessHash( record.value("accessHash").toLongLong() );
        user.setInactive( record.value("inactive").toBool() );
        user.setPhone( record.value("phone").toString() );
        user.setFirstName( record.value("firstName").toString() );
        user.setLastName( record.value("lastName").toString() );
        user.setUsername( record.value("username").toString() );
        user.setClassType( static_cast<User::UserType>(record.value("type").toLongLong()) );
        user.setPhoto(photo);
        user.setStatus(status);

        DbUser duser;
        duser.user = user;

        emit userFounded(duser);
    }
}

void DatabaseCore::readChats()
{
    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM Chats");

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }

    while(query.next())
    {
        const QSqlRecord &record = query.record();

        ChatPhoto photo(ChatPhoto::typeChatPhotoEmpty);
        if(record.value("photoId").toLongLong() != 0)
        {
            FileLocation bigPhoto(FileLocation::typeFileLocation);
            bigPhoto.setLocalId( record.value("photoBigLocalId").toLongLong() );
            bigPhoto.setSecret( record.value("photoBigSecret").toLongLong() );
            bigPhoto.setDcId( record.value("photoBigDcId").toLongLong() );
            bigPhoto.setVolumeId( record.value("photoBigVolumeId").toLongLong() );

            FileLocation smallPhoto(FileLocation::typeFileLocation);
            smallPhoto.setLocalId( record.value("photoSmallLocalId").toLongLong() );
            smallPhoto.setSecret( record.value("photoSmallSecret").toLongLong() );
            smallPhoto.setDcId( record.value("photoSmallDcId").toLongLong() );
            smallPhoto.setVolumeId( record.value("photoSmallVolumeId").toLongLong() );

            photo.setClassType(ChatPhoto::typeChatPhoto);
            photo.setPhotoBig(bigPhoto);
            photo.setPhotoSmall(smallPhoto);
        }

        Chat chat(Chat::typeChatEmpty);
        chat.setId( record.value("id").toLongLong() );
        chat.setAccessHash( record.value("accessHash").toLongLong() );
        chat.setVersion( record.value("version").toLongLong() );
        chat.setVenue( record.value("venue").toString() );
        chat.setTitle( record.value("title").toString() );
        chat.setAddress( record.value("address").toString() );
        chat.setParticipantsCount( record.value("participantsCount").toLongLong() );
        chat.setDate( record.value("date").toLongLong() );
        chat.setParticipantsCount( record.value("participantsCount").toLongLong() );
        chat.setCheckedIn( record.value("checkedIn").toBool() );
        chat.setLeft( record.value("left").toBool() );
        chat.setClassType( static_cast<Chat::ChatType>(record.value("type").toLongLong()) );
        chat.setPhoto(photo);

        DbChat dchat;
        dchat.chat = chat;

        emit chatFounded(dchat);
    }
}

void DatabaseCore::reconnect()
{
    p->db.open();
    update_db();
    init_buffer();
}

void DatabaseCore::init_buffer()
{
}

void DatabaseCore::update_db()
{
}

QList<qint32> DatabaseCore::stringToUsers(const QString &str)
{
    QList<qint32> res;
    const QStringList &list = str.split(",", QString::SkipEmptyParts);
    foreach(const QString &l, list)
        res << l.toInt();

    return res;
}

QString DatabaseCore::usersToString(const QList<qint32> &users)
{
    QStringList list;
    foreach(const qint32 u, users)
        list << QString::number(u);

    return list.join(",");
}

void DatabaseCore::insertAudio(const Audio &audio)
{
    if(audio.id() == 0 || audio.classType() == Audio::typeAudioEmpty)
        return;

    begin();
    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO Audios (id, dcId, mimeType, duration, date, size, accessHash, userId, type) "
                  "VALUES (:id, :dcId, :mimeType, :duration, :date, :size, :accessHash, :userId, :type);");

    query.bindValue(":id", audio.id());
    query.bindValue(":dcId", audio.dcId());
    query.bindValue(":mimeType", audio.mimeType());
    query.bindValue(":duration", audio.duration());
    query.bindValue(":date", audio.date());
    query.bindValue(":size", audio.size());
    query.bindValue(":accessHash", audio.accessHash());
    query.bindValue(":userId", audio.userId());
    query.bindValue(":type", audio.classType());

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }
}

void DatabaseCore::insertVideo(const Video &video)
{
    if(video.id() == 0 || video.classType() == Video::typeVideoEmpty)
        return;

    begin();
    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO Videos (id, dcId, caption, mimeType, date, duration, h, size, accessHash, userId, w, type) "
                  "VALUES (:id, :dcId, :caption, :mimeType, :date, :duration, :h, :size, :accessHash, :userId, :w, :type);");

    query.bindValue(":id", video.id());
    query.bindValue(":dcId", video.dcId());
    query.bindValue(":caption", video.caption());
    query.bindValue(":mimeType", video.mimeType());
    query.bindValue(":date", video.date());
    query.bindValue(":duration", video.duration());
    query.bindValue(":h", video.h());
    query.bindValue(":w", video.w());
    query.bindValue(":size", video.size());
    query.bindValue(":accessHash", video.accessHash());
    query.bindValue(":userId", video.userId());
    query.bindValue(":type", video.classType());

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }

    insertPhotoSize(video.id(), QList<PhotoSize>()<<video.thumb());
}

void DatabaseCore::insertDocument(const Document &document)
{
    if(document.id() == 0 || document.classType() == Document::typeDocumentEmpty)
        return;

    begin();
    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO Documents (id, dcId, mimeType, date, fileName, size, accessHash, userId, type) "
                  "VALUES (:id, :dcId, :mimeType, :date, :fileName, :size, :accessHash, :userId, :type);");

    query.bindValue(":id", document.id());
    query.bindValue(":dcId", document.dcId());
    query.bindValue(":mimeType", document.mimeType());
    query.bindValue(":date", document.date());
    query.bindValue(":fileName", document.fileName());
    query.bindValue(":size", document.size());
    query.bindValue(":accessHash", document.accessHash());
    query.bindValue(":userId", document.userId());
    query.bindValue(":type", document.classType());

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }

    insertPhotoSize(document.id(), QList<PhotoSize>()<<document.thumb());
}

void DatabaseCore::insertGeo(int id, const GeoPoint &geo)
{
    if(id == 0 || geo.classType() == GeoPoint::typeGeoPointEmpty)
        return;

    begin();
    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO Audios (id, longitude, lat) "
                  "VALUES (:id, :longitude, :lat);");

    query.bindValue(":id", id);
    query.bindValue(":longitude", geo.longitude());
    query.bindValue(":lat", geo.lat());

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }
}

void DatabaseCore::insertPhoto(const Photo &photo)
{
    if(photo.id() == 0 || photo.classType() == Photo::typePhotoEmpty)
        return;

    begin();
    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO Photos (id, caption, date, accessHash, userId) "
                  "VALUES (:id, :caption, :date, :accessHash, :userId);");

    query.bindValue(":id", photo.id());
    query.bindValue(":caption", photo.caption());
    query.bindValue(":date", photo.date());
    query.bindValue(":accessHash", photo.accessHash());
    query.bindValue(":userId", photo.userId());

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return;
    }

    insertPhotoSize(photo.id(), photo.sizes());
}

void DatabaseCore::insertPhotoSize(int pid, const QList<PhotoSize> &sizes)
{
    begin();
    foreach(const PhotoSize &size, sizes)
    {
        if(size.classType() == PhotoSize::typePhotoSizeEmpty)
            continue;

        QSqlQuery query(p->db);
        query.prepare("INSERT OR REPLACE INTO PhotoSizes (pid, h, type, size, w, locationLocalId, locationSecret, locationDcId, locationVolumeId) "
                      "VALUES (:pid, :h, :type, :size, :w, :locationLocalId, :locationSecret, :locationDcId, :locationVolumeId);");

        query.bindValue(":pid", pid);
        query.bindValue(":h", size.h());
        query.bindValue(":w", size.w());
        query.bindValue(":type", size.type());
        query.bindValue(":size", size.size());

        const FileLocation &location = size.location();
        query.bindValue(":locationLocalId", location.localId());
        query.bindValue(":locationSecret", location.secret());
        query.bindValue(":locationDcId", location.dcId());
        query.bindValue(":locationVolumeId", location.volumeId());

        bool res = query.exec();
        if(!res)
            qDebug() << __FUNCTION__ << query.lastError();
    }
}

Audio DatabaseCore::readAudio(qint64 id)
{
    Audio audio(Audio::typeAudioEmpty);
    if(!id)
        return audio;

    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM Audios WHERE id=:id");
    query.bindValue(":id", id);

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return audio;
    }

    if(!query.next())
        return audio;

    const QSqlRecord &record = query.record();

    audio.setId( record.value("id").toLongLong() );
    audio.setDcId( record.value("dcId").toLongLong() );
    audio.setMimeType( record.value("mimeType").toString() );
    audio.setDuration( record.value("duration").toLongLong() );
    audio.setDate( record.value("date").toLongLong() );
    audio.setSize( record.value("size").toLongLong() );
    audio.setAccessHash( record.value("accessHash").toLongLong() );
    audio.setUserId( record.value("userId").toLongLong() );
    audio.setClassType( static_cast<Audio::AudioType>(record.value("type").toLongLong()) );

    return audio;
}

Video DatabaseCore::readVideo(qint64 id)
{
    Video video(Video::typeVideoEmpty);
    if(!id)
        return video;

    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM Videos WHERE id=:id");
    query.bindValue(":id", id);

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return video;
    }

    if(!query.next())
        return video;

    const QSqlRecord &record = query.record();

    video.setId( record.value("id").toLongLong() );
    video.setDcId( record.value("dcId").toLongLong() );
    video.setMimeType( record.value("mimeType").toString() );
    video.setCaption( record.value("caption").toString() );
    video.setDate( record.value("date").toLongLong() );
    video.setDuration( record.value("duration").toLongLong() );
    video.setSize( record.value("size").toLongLong() );
    video.setW( record.value("w").toLongLong() );
    video.setH( record.value("h").toLongLong() );
    video.setAccessHash( record.value("accessHash").toLongLong() );
    video.setUserId( record.value("userId").toLongLong() );
    video.setClassType( static_cast<Video::VideoType>(record.value("type").toLongLong()) );

    return video;
}

Document DatabaseCore::readDocument(qint64 id)
{
    Document document(Document::typeDocumentEmpty);
    if(!id)
        return document;

    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM Documents WHERE id=:id");
    query.bindValue(":id", id);

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return document;
    }

    if(!query.next())
        return document;

    const QSqlRecord &record = query.record();

    document.setId( record.value("id").toLongLong() );
    document.setDcId( record.value("dcId").toLongLong() );
    document.setMimeType( record.value("mimeType").toString() );
    document.setDate( record.value("date").toLongLong() );
    document.setFileName( record.value("fileName").toString() );
    document.setSize( record.value("size").toLongLong() );
    document.setAccessHash( record.value("accessHash").toLongLong() );
    document.setUserId( record.value("userId").toLongLong() );
    document.setClassType( static_cast<Document::DocumentType>(record.value("type").toLongLong()) );

    return document;
}

GeoPoint DatabaseCore::readGeo(qint64 id)
{
    GeoPoint geo(GeoPoint::typeGeoPointEmpty);
    if(!id)
        return geo;

    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM Geos WHERE id=:id");
    query.bindValue(":id", id);

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return geo;
    }

    if(!query.next())
        return geo;

    const QSqlRecord &record = query.record();

    geo.setLongitude( record.value("longitude").toDouble() );
    geo.setLat( record.value("lat").toDouble() );
    geo.setClassType(GeoPoint::typeGeoPoint);

    return geo;
}

Photo DatabaseCore::readPhoto(qint64 id)
{
    Photo photo;
    if(!id)
        return photo;

    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM Photos WHERE id=:id");
    query.bindValue(":id", id);

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return photo;
    }

    if(!query.next())
        return photo;

    const QSqlRecord &record = query.record();

    photo.setId( record.value("id").toLongLong() );
    photo.setCaption( record.value("caption").toString() );
    photo.setDate( record.value("date").toLongLong() );
    photo.setAccessHash( record.value("accessHash").toLongLong() );
    photo.setUserId( record.value("userId").toLongLong() );
    photo.setSizes( readPhotoSize(id) );
    photo.setClassType(Photo::typePhoto);

    return photo;
}

QList<PhotoSize> DatabaseCore::readPhotoSize(qint64 pid)
{
    QList<PhotoSize> list;
    if(!pid)
        return list;

    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM PhotoSizes WHERE pid=:pid");
    query.bindValue(":pid", pid);

    bool res = query.exec();
    if(!res)
    {
        qDebug() << __FUNCTION__ << query.lastError();
        return list;
    }

    while(query.next())
    {
        const QSqlRecord &record = query.record();

        FileLocation location(FileLocation::typeFileLocation);
        location.setLocalId( record.value("locationLocalId").toLongLong() );
        location.setSecret( record.value("locationSecret").toLongLong() );
        location.setDcId( record.value("locationDcId").toLongLong() );
        location.setVolumeId( record.value("locationVolumeId").toLongLong() );

        PhotoSize psize;
        psize.setH( record.value("h").toLongLong() );
        psize.setW( record.value("w").toLongLong() );
        psize.setType( record.value("type").toString() );
        psize.setSize( record.value("size").toLongLong() );
        psize.setLocation(location);

        list << psize;
    }

    return list;
}

void DatabaseCore::begin()
{
    if(p->commit_timer)
    {
        killTimer(p->commit_timer);
        p->commit_timer = startTimer(1000);
        return;
    }

    QSqlQuery query( p->db );
    query.prepare( "BEGIN" );
    query.exec();

    p->commit_timer = startTimer(1000);
}

void DatabaseCore::commit()
{
    if(!p->commit_timer)
        return;

    QSqlQuery query( p->db );
    query.prepare( "COMMIT" );
    query.exec();

    killTimer(p->commit_timer);
    p->commit_timer = 0;
}

void DatabaseCore::timerEvent(QTimerEvent *e)
{
    if(e->timerId() == p->commit_timer)
    {
        commit();
    }
}

DatabaseCore::~DatabaseCore()
{
    delete p;
}

