/*
    Copyright (C) 2014 Aseman
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

#include "asemantools/asemanapplication.h"
#include "asemantools/asemantools.h"
#include "telegramqml.h"
#include "userdata.h"
#include "database.h"
#include "objects/types.h"

#include <secret/secretchat.h>
#include <secret/decrypter.h>
#include <telegram.h>
#include <types/decryptedmessage.h>
#include <limits>

#include <QPointer>
#include <QTimerEvent>
#include <QDebug>
#include <QHash>
#include <QDateTime>
#include <QMimeDatabase>
#include <QMimeType>
#include <QImage>
#include <QImageReader>
#include <QImageWriter>
#include <QBuffer>

TelegramQmlPrivate *telegramp_qml_tmp = 0;
bool checkDialogLessThan( qint64 a, qint64 b );
bool checkMessageLessThan( qint64 a, qint64 b );

class TelegramQmlPrivate
{
public:
    UserData *userdata;
    Database *database;
    Telegram *telegram;
    Settings *tsettings;

    QString phoneNumber;
    QString configPath;
    QString publicKeyFile;

    bool online;
    bool invisible;
    int unreadCount;

    bool authNeeded;
    bool authLoggedIn;
    bool phoneRegistered;
    bool phoneInvited;
    bool phoneChecked;

    QString authSignUpError;
    QString authSignInError;
    QString error;

    qint64 logout_req_id;
    qint64 checkphone_req_id;
    qint64 profile_upload_id;

    QHash<qint64,DialogObject*> dialogs;
    QHash<qint64,MessageObject*> messages;
    QHash<qint64,ChatObject*> chats;
    QHash<qint64,UserObject*> users;
    QHash<qint64,ChatFullObject*> chatfulls;
    QHash<qint64,ContactObject*> contacts;
    QHash<qint64,EncryptedMessageObject*> encmessages;
    QHash<qint64,EncryptedChatObject*> encchats;

    QHash<qint64,DialogObject*> fakeDialogs;

    QList<qint64> dialogs_list;
    QHash<qint64, QList<qint64> > messages_list;
    QMap<qint64, WallPaperObject*> wallpapers_map;

    QHash<qint64,MessageObject*> pend_messages;
    QHash<qint64,FileLocationObject*> downloads;
    QHash<qint64,MessageObject*> uploads;
    QHash<qint64,FileLocationObject*> accessHashes;

    QSet<QObject*> garbages;

    QHash<int, QPair<qint64,qint64> > typing_timers;
    int upd_dialogs_timer;
    int garbage_checker_timer;

    DialogObject *nullDialog;
    MessageObject *nullMessage;
    ChatObject *nullChat;
    UserObject *nullUser;
    FileLocationObject *nullFile;
    WallPaperObject *nullWallpaper;
    UploadObject *nullUpload;
    ChatFullObject *nullChatFull;
    ContactObject *nullContact;
    FileLocationObject *nullLocation;
    EncryptedChatObject *nullEncryptedChat;
    EncryptedMessageObject *nullEncryptedMessage;

    QMimeDatabase mime_db;

    qint32 msg_send_id_counter;
    qint64 msg_send_random_id;
};

TelegramQml::TelegramQml(QObject *parent) :
    QObject(parent)
{
    p = new TelegramQmlPrivate;
    p->upd_dialogs_timer = 0;
    p->garbage_checker_timer = 0;
    p->unreadCount = 0;
    p->online = false;
    p->invisible = false;
    p->msg_send_id_counter = INT_MAX - 100000;
    p->msg_send_random_id = 0;

    p->userdata = 0;
    p->telegram = 0;
    p->tsettings = 0;
    p->authNeeded = false;
    p->authLoggedIn = false;
    p->phoneRegistered = false;
    p->phoneInvited = false;
    p->phoneChecked = false;

    p->logout_req_id = 0;
    p->checkphone_req_id = 0;
    p->profile_upload_id = 0;

    p->nullDialog = new DialogObject( Dialog(), this );
    p->nullMessage = new MessageObject(Message(Message::typeMessageEmpty), this);
    p->nullChat = new ChatObject(Chat(Chat::typeChatEmpty), this);
    p->nullUser = new UserObject(User(User::typeUserEmpty), this);
    p->nullFile = new FileLocationObject(FileLocation(FileLocation::typeFileLocationUnavailable), this);
    p->nullWallpaper = new WallPaperObject(WallPaper(WallPaper::typeWallPaperSolid), this);
    p->nullUpload = new UploadObject(this);
    p->nullChatFull = new ChatFullObject(ChatFull(), this);
    p->nullContact = new ContactObject(Contact(), this);
    p->nullLocation = new FileLocationObject(FileLocation(), this);
    p->nullEncryptedChat = new EncryptedChatObject(EncryptedChat(), this);
    p->nullEncryptedMessage = new EncryptedMessageObject(EncryptedMessage(), this);
}

QString TelegramQml::phoneNumber() const
{
    return p->phoneNumber;
}

void TelegramQml::setPhoneNumber(const QString &phone)
{
    if( p->phoneNumber == phone )
        return;

    p->phoneNumber = phone;
    emit phoneNumberChanged();
    emit downloadPathChanged();
    try_init();

    if( p->userdata )
        delete p->userdata;

    p->userdata = new UserData(phone, this);
    emit userDataChanged();

    p->database = new Database(phone, this);

    connect(p->database, SIGNAL(chatFounded(Chat))         , SLOT(dbChatFounded(Chat))         );
    connect(p->database, SIGNAL(userFounded(User))         , SLOT(dbUserFounded(User))         );
    connect(p->database, SIGNAL(dialogFounded(Dialog,bool)), SLOT(dbDialogFounded(Dialog,bool)));
    connect(p->database, SIGNAL(messageFounded(Message))   , SLOT(dbMessageFounded(Message))   );
}

QString TelegramQml::downloadPath() const
{
    return AsemanApplication::homePath() + "/" + phoneNumber() + "/downloads";
}

QString TelegramQml::configPath() const
{
    return p->configPath;
}

void TelegramQml::setConfigPath(const QString &conf)
{
    if( p->configPath == conf )
        return;

    p->configPath = conf;
    emit configPathChanged();
    try_init();
}

QString TelegramQml::publicKeyFile() const
{
    return p->publicKeyFile;
}

void TelegramQml::setPublicKeyFile(const QString &file)
{
    if( p->publicKeyFile == file )
        return;

    p->publicKeyFile = file;
    emit publicKeyFileChanged();
    try_init();
}

UserData *TelegramQml::userData() const
{
    return p->userdata;
}

Database *TelegramQml::database() const
{
    return p->database;
}

Telegram *TelegramQml::telegram() const
{
    return p->telegram;
}

qint64 TelegramQml::me() const
{
    if( p->telegram )
        return p->telegram->ourId();
    else
        return 0;
}

bool TelegramQml::online() const
{
    return p->online;
}

void TelegramQml::setOnline(bool stt)
{
    if( p->online == stt )
        return;

    p->online = stt;
    if( p->telegram && p->authLoggedIn )
        p->telegram->accountUpdateStatus(!p->online || p->invisible);

    emit onlineChanged();
}

void TelegramQml::setInvisible(bool stt)
{
    if( p->invisible == stt )
        return;

    p->invisible = stt;
    emit invisibleChanged();

    p->telegram->accountUpdateStatus(true);
}

bool TelegramQml::invisible() const
{
    return p->invisible;
}

int TelegramQml::unreadCount()
{
    return p->unreadCount;
}

bool TelegramQml::authNeeded() const
{
    return p->authNeeded;
}

bool TelegramQml::authLoggedIn() const
{
    return p->authLoggedIn;
}

bool TelegramQml::authPhoneChecked() const
{
    return p->phoneChecked;
}

bool TelegramQml::authPhoneRegistered() const
{
    return p->phoneRegistered;
}

bool TelegramQml::authPhoneInvited() const
{
    return p->phoneInvited;
}

bool TelegramQml::connected() const
{
    if( !p->telegram )
        return false;

    return p->telegram->isConnected();
}

QString TelegramQml::authSignUpError() const
{
    return p->authSignUpError;
}

QString TelegramQml::authSignInError() const
{
    return p->authSignInError;
}

QString TelegramQml::error() const
{
    return p->error;
}

DialogObject *TelegramQml::dialog(qint64 id) const
{
    DialogObject *res = p->dialogs.value(id);
    if( !res )
        res = p->nullDialog;
    return res;
}

MessageObject *TelegramQml::message(qint64 id) const
{
    MessageObject *res = p->messages.value(id);
    if( !res )
        res = p->nullMessage;
    return res;
}

ChatObject *TelegramQml::chat(qint64 id) const
{
    ChatObject *res = p->chats.value(id);
    if( !res )
        res = p->nullChat;
    return res;
}

UserObject *TelegramQml::user(qint64 id) const
{
    UserObject *res = p->users.value(id);
    if( !res )
        res = p->nullUser;
    return res;
}

qint64 TelegramQml::messageDialogId(qint64 id) const
{
    MessageObject *msg = p->messages.value(id);
    if(!msg)
        return 0;

    qint64 dId = msg->toId()->chatId();
    if( dId == 0 )
        dId = msg->out()? msg->toId()->userId() : msg->fromId();

    return dId;
}

DialogObject *TelegramQml::messageDialog(qint64 id) const
{
    qint64 dId = messageDialogId(id);
    DialogObject *dlg = p->dialogs.value(dId);
    if(!dlg)
        dlg = p->nullDialog;

    return dlg;
}

WallPaperObject *TelegramQml::wallpaper(qint64 id) const
{
    WallPaperObject *res = p->wallpapers_map.value(id);
    if( !res )
        res = p->nullWallpaper;
    return res;
}

MessageObject *TelegramQml::upload(qint64 id) const
{
    MessageObject *res = p->uploads.value(id);
    if( !res )
        res = p->nullMessage;
    return res;
}

ChatFullObject *TelegramQml::chatFull(qint64 id) const
{
    ChatFullObject *res = p->chatfulls.value(id);
    if( !res )
        res = p->nullChatFull;
    return res;
}

ContactObject *TelegramQml::contact(qint64 id) const
{
    ContactObject *res = p->contacts.value(id);
    if( !res )
        res = p->nullContact;
    return res;
}

EncryptedChatObject *TelegramQml::encryptedChat(qint64 id) const
{
    EncryptedChatObject *res = p->encchats.value(id);
    if( !res )
        res = p->nullEncryptedChat;
    return res;
}

FileLocationObject *TelegramQml::locationOf(qint64 id, qint64 dcId, qint64 accessHash)
{
    if( p->accessHashes.contains(accessHash) )
        return p->accessHashes.value(accessHash);

    FileLocation location(FileLocation::typeFileLocation);
    FileLocationObject *obj = new FileLocationObject(location,this);
    obj->setId(id);
    obj->setDcId(dcId);
    obj->setAccessHash(accessHash);

    p->accessHashes[accessHash] = obj;
    return obj;
}

FileLocationObject *TelegramQml::locationOfDocument(DocumentObject *doc)
{
    FileLocationObject *res = locationOf(doc->id(), doc->dcId(), doc->accessHash());
    res->setFileName(doc->fileName());
    res->setMimeType(doc->mimeType());

    return res;
}

FileLocationObject *TelegramQml::locationOfVideo(VideoObject *vid)
{
    return locationOf(vid->id(), vid->dcId(), vid->accessHash());
}

FileLocationObject *TelegramQml::locationOfAudio(AudioObject *aud)
{
    return locationOf(aud->id(), aud->dcId(), aud->accessHash());
}

DialogObject *TelegramQml::fakeDialogObject(qint64 id, bool isChat)
{
    if( p->fakeDialogs.contains(id) )
        return p->fakeDialogs.value(id);

    Peer peer(isChat? Peer::typePeerChat : Peer::typePeerUser);
    if( isChat )
        peer.setChatId(id);
    else
        peer.setUserId(id);

    Dialog dialog;
    dialog.setPeer(peer);

    DialogObject *obj = new DialogObject(dialog);
    p->fakeDialogs[id] = obj;
    return obj;
}

DialogObject *TelegramQml::nullDialog() const
{
    return p->nullDialog;
}

MessageObject *TelegramQml::nullMessage() const
{
    return p->nullMessage;
}

ChatObject *TelegramQml::nullChat() const
{
    return p->nullChat;
}

UserObject *TelegramQml::nullUser() const
{
    return p->nullUser;
}

WallPaperObject *TelegramQml::nullWallpaper() const
{
    return p->nullWallpaper;
}

UploadObject *TelegramQml::nullUpload() const
{
    return p->nullUpload;
}

ChatFullObject *TelegramQml::nullChatFull() const
{
    return p->nullChatFull;
}

ContactObject *TelegramQml::nullContact() const
{
    return p->nullContact;
}

FileLocationObject *TelegramQml::nullLocation() const
{
    return p->nullLocation;
}

EncryptedChatObject *TelegramQml::nullEncryptedChat() const
{
    return p->nullEncryptedChat;
}

EncryptedMessageObject *TelegramQml::nullEncryptedMessage() const
{
    return p->nullEncryptedMessage;
}

QString TelegramQml::fileLocation(FileLocationObject *l)
{
    const QString & dpath = downloadPath();
    const QString & fname = l->accessHash()!=0? QString::number(l->id()) :
                                                QString("%1_%2").arg(l->volumeId()).arg(l->localId());

    QDir().mkpath(dpath);

    const QStringList & av_files = QDir(dpath).entryList(QDir::Files);
    foreach( const QString & f, av_files )
        if( QFileInfo(f).baseName() == fname )
            return dpath + "/" + f;

    return dpath + "/" + fname;
}

QList<qint64> TelegramQml::dialogs() const
{
    return p->dialogs_list;
}

QList<qint64> TelegramQml::messages( qint64 did ) const
{
    return p->messages_list[did];
}

QList<qint64> TelegramQml::wallpapers() const
{
    return p->wallpapers_map.keys();
}

QList<qint64> TelegramQml::uploads() const
{
    return p->uploads.keys();
}

QList<qint64> TelegramQml::contacts() const
{
    return p->contacts.keys();
}

void TelegramQml::authLogout()
{
    if( !p->telegram )
        return;
    if( p->logout_req_id )
        return;

    p->logout_req_id = p->telegram->authLogOut();
}

void TelegramQml::authSendCall()
{
    if( !p->telegram )
        return;

    p->telegram->authSendCall();
}

void TelegramQml::authSendInvites(const QStringList &phoneNumbers, const QString &inviteText)
{
    if( !p->telegram )
        return;

    p->telegram->authSendInvites(phoneNumbers, inviteText);
}

void TelegramQml::authSignIn(const QString &code)
{
    if( !p->telegram )
        return;

    p->telegram->authSignIn(code);

    p->authNeeded = false;
    p->authSignUpError = "";
    p->authSignInError = "";
    emit authSignInErrorChanged();
    emit authSignUpErrorChanged();
    emit authNeededChanged();
}

void TelegramQml::authSignUp(const QString &code, const QString &firstName, const QString &lastName)
{
    if( !p->telegram )
        return;

    p->telegram->authSignUp(code, firstName, lastName);

    p->authNeeded = false;
    p->authSignUpError = "";
    p->authSignInError = "";
    emit authSignInErrorChanged();
    emit authSignUpErrorChanged();
    emit authNeededChanged();
}

void TelegramQml::sendMessage(qint64 dId, const QString &msg)
{
    if( !p->telegram )
        return;

    DialogObject *dlg = p->dialogs.value(dId);
    if(!dlg)
        return;

    qint64 sendId;

    Message message = newMessage(dId);
    message.setMessage(msg);

    p->msg_send_random_id = generateRandomId();
    if(dlg->encrypted())
    {
        sendId = p->telegram->messagesSendEncrypted(dId, p->msg_send_random_id, msg);
    }
    else
    {
        InputPeer peer(message.toId().chatId()? InputPeer::typeInputPeerChat : InputPeer::typeInputPeerContact);
        peer.setChatId(message.toId().chatId());
        peer.setUserId(message.toId().userId());

        sendId = p->telegram->messagesSendMessage(peer, p->msg_send_random_id, msg);

    }

    insertMessage(message, dlg->encrypted(), false, true);

    MessageObject *msgObj = p->messages.value(message.id());
    msgObj->setSent(false);

    p->pend_messages[sendId] = msgObj;

    timerUpdateDialogs();

    if(dlg->encrypted())
        messagesSendEncrypted_slt(sendId, message.date(), EncryptedFile());
}

void TelegramQml::forwardMessage(qint64 msgId, qint64 peerId)
{
    bool isChat = p->chats.contains(peerId);
    InputPeer peer( isChat? InputPeer::typeInputPeerChat : InputPeer::typeInputPeerContact );
    if(isChat)
        peer.setChatId(peerId);
    else
        peer.setUserId(peerId);

    p->telegram->messagesForwardMessage(peer, msgId);
}

void TelegramQml::deleteMessage(qint64 msgId)
{
    p->telegram->messagesDeleteMessages( QList<qint32>()<<msgId );
}

void TelegramQml::messagesCreateChat(const QList<qint32> &users, const QString &topic)
{
    QList<InputUser> inputUsers;
    foreach( qint32 user, users )
    {
        InputUser input(InputUser::typeInputUserContact);
        input.setUserId(user);

        inputUsers << input;
    }

    p->telegram->messagesCreateChat(inputUsers, topic);
}

void TelegramQml::messagesCreateEncryptedChat(qint64 userId)
{
    if( !p->telegram )
        return;

    UserObject *user = p->users.value(userId);
    if(!user)
        return;

    InputUser input(InputUser::typeInputUserContact);
    input.setUserId(user->id());
    input.setAccessHash(user->accessHash());

    p->telegram->messagesCreateEncryptedChat(input);
}

void TelegramQml::messagesAcceptEncryptedChat(qint32 chatId)
{
    if( !p->telegram )
        return;

    p->telegram->messagesAcceptEncryptedChat(chatId);
}

void TelegramQml::messagesDiscardEncryptedChat(qint32 chatId)
{
    if( !p->telegram )
        return;

    p->telegram->messagesDiscardEncryptedChat(chatId);
}

bool TelegramQml::sendFile(qint64 dId, const QString &fpath)
{
    QString file = fpath;
    if( file.left(7) == "file://" )
        file = file.mid(7);

    if( !QFileInfo::exists(file) )
        return false;
    if( !p->telegram )
        return false;

    DialogObject *dlg = dialog(dId);
    if( !dlg )
        return false;

    Message message = newMessage(dId);
    InputPeer peer(message.toId().chatId()? InputPeer::typeInputPeerChat : InputPeer::typeInputPeerContact);
    peer.setChatId(message.toId().chatId());
    peer.setUserId(message.toId().userId());

    qint64 fileId;
    p->msg_send_random_id = generateRandomId();
    const QMimeType & t = p->mime_db.mimeTypeForFile(file);
    if( t.name().contains("image/") )
    {
        if(dlg->encrypted())
            fileId = p->telegram->messagesSendEncryptedPhoto(dId, p->msg_send_random_id, file);
        else
            fileId = p->telegram->messagesSendPhoto(peer, p->msg_send_random_id, file);
    }
    else
    if( t.name().contains("video/") )
    {
        QString thumbnail = AsemanApplication::tempPath()+"/cutegram_thumbnail_" + QUuid::createUuid().toString() + ".jpg";
        int width = 0;
        int height = 0;

        if( !AsemanTools::createVideoThumbnail(fpath, thumbnail) )
            thumbnail.clear();
        else
        {
            QImageReader reader(thumbnail);
            QSize size = reader.size();
            width = size.width();
            height = size.height();
        }

        if(dlg->encrypted())
        {
            QByteArray thumbData;
            QFile thumbFile(thumbnail);
            if(thumbFile.open(QFile::ReadOnly))
            {
                thumbData = thumbFile.readAll();
                thumbFile.close();
            }

            fileId = p->telegram->messagesSendEncryptedVideo(dId, p->msg_send_random_id, file, thumbData);
        }
        else
            fileId = p->telegram->messagesSendVideo(peer, p->msg_send_random_id, file, 0, width, height, thumbnail);
    }
    else
    if( dlg->encrypted() )
        return false;
    else
    if( t.name().contains("audio/") )
        fileId = p->telegram->messagesSendAudio(peer, p->msg_send_random_id, file, 0);
    else
        fileId = p->telegram->messagesSendDocument(peer, p->msg_send_random_id, file);

    insertMessage(message, false, false, true);

    MessageObject *msgObj = p->messages.value(message.id());
    msgObj->setSent(false);

    UploadObject *upload = msgObj->upload();
    upload->setFileId(fileId);
    upload->setLocation(file);
    upload->setTotalSize(QFileInfo(file).size());

    p->uploads[fileId] = msgObj;
    emit uploadsChanged();
    return true;
}

void TelegramQml::getFile(FileLocationObject *l, qint64 type, qint32 fileSize)
{
    if( !p->telegram )
        return;
    if(l->accessHash()==0 && l->volumeId()==0 && l->localId()==0)
        return;

    const QString & download_file = fileLocation(l);
    if( QFile::exists(download_file) )
    {
        l->download()->setLocation("file://"+download_file);
        return;
    }

    InputFileLocation input(static_cast<InputFileLocation::InputFileLocationType>(type));
    input.setAccessHash(l->accessHash());
    input.setId(l->id());
    input.setLocalId(l->localId());
    input.setSecret(l->secret());
    input.setVolumeId(l->volumeId());

    qint64 fileId = p->telegram->uploadGetFile(input, fileSize, l->dcId());
    p->downloads[fileId] = l;

    l->download()->setFileId(fileId);
}

void TelegramQml::getFileJustCheck(FileLocationObject *l)
{
    if( !p->telegram )
        return;

    const QString & download_file = fileLocation(l);
    if( QFile::exists(download_file) )
        l->download()->setLocation("file://"+download_file);
}

Message TelegramQml::newMessage(qint64 dId)
{
    DialogObject *dlg = dialog(dId);
    if( !dlg )
        return Message(Message::typeMessageEmpty);

    Peer to_peer(static_cast<Peer::PeerType>(dlg->peer()->classType()));
    to_peer.setChatId(dlg->peer()->chatId());
    to_peer.setUserId(dlg->peer()->userId());

    if(dlg->encrypted())
    {
        Peer encPeer(Peer::typePeerChat);
        encPeer.setChatId(dId);
        to_peer = encPeer;
    }

    static qint32 msgId = INT_MAX-100000;
    msgId++;

    Message message(Message::typeMessage);
    message.setId(msgId);
    message.setDate( QDateTime::currentDateTime().toTime_t() );
    message.setFromId( p->telegram->ourId() );
    message.setOut(true);
    message.setToId(to_peer);
    message.setUnread(true);

    return message;
}

SecretChat *TelegramQml::getSecretChat(qint64 chatId)
{
    const QList<SecretChat*> & chats = p->tsettings->secretChats();
    foreach(SecretChat *c, chats)
        if(c->chatId() == chatId)
            return c;

    return  0;
}

void TelegramQml::cancelSendGet(qint64 fileId)
{
    if( !p->telegram )
        return;

    p->telegram->uploadCancelFile(fileId);
}

void TelegramQml::setProfilePhoto(const QString &fileName)
{
    if( !p->telegram )
        return;
    if( p->profile_upload_id )
        return;

    QFileInfo file(fileName);
    QImageReader reader(fileName);
    QSize size = reader.size();
    qreal ratio = (qreal)size.width()/size.height();
    if( size.width()>1024 && size.width()>size.height() )
    {
        size.setWidth(1024);
        size.setHeight(1024/ratio);
    }
    else
    if( size.height()>1024 && size.height()>size.width() )
    {
        size.setHeight(1024);
        size.setWidth(1024*ratio);
    }

    reader.setScaledSize(size);
    const QImage & img = reader.read();

    QByteArray data;
    QBuffer buffer(&data);
    buffer.open(QBuffer::WriteOnly);

    QImageWriter writer(&buffer, "png");
    writer.write(img);

    buffer.close();

    p->profile_upload_id = p->telegram->photosUploadProfilePhoto(data, file.fileName() );
}

void TelegramQml::timerUpdateDialogs(bool duration)
{
    if( p->upd_dialogs_timer )
        killTimer(p->upd_dialogs_timer);

    p->upd_dialogs_timer = startTimer(duration);
}

void TelegramQml::try_init()
{
    if( p->telegram )
    {
        delete p->telegram;
        p->telegram = 0;
    }
    if( p->phoneNumber.isEmpty() || p->publicKeyFile.isEmpty() || p->configPath.isEmpty() )
        return;

    p->telegram = new Telegram(p->phoneNumber, p->configPath, p->publicKeyFile);

    p->tsettings = Settings::getInstance();
    p->tsettings->loadSettings(p->phoneNumber, p->configPath, p->publicKeyFile);

    connect( p->telegram, SIGNAL(authNeeded())                          , SLOT(authNeeded_slt())                           );
    connect( p->telegram, SIGNAL(authLoggedIn())                        , SLOT(authLoggedIn_slt())                         );
    connect( p->telegram, SIGNAL(authLogOutAnswer(qint64,bool))         , SLOT(authLogOut_slt(qint64,bool))                );
    connect( p->telegram, SIGNAL(authCheckPhoneAnswer(qint64,bool,bool)), SLOT(authCheckPhone_slt(qint64,bool,bool))       );
    connect( p->telegram, SIGNAL(authSendCallAnswer(qint64,bool))       , SLOT(authSendCall_slt(qint64,bool))              );
    connect( p->telegram, SIGNAL(authSendCodeAnswer(qint64,bool,qint32)), SLOT(authSendCode_slt(qint64,bool,qint32))       );
    connect( p->telegram, SIGNAL(authSendInvitesAnswer(qint64,bool))    , SLOT(authSendInvites_slt(qint64,bool))           );
    connect( p->telegram, SIGNAL(authSignInError(qint64,qint32,QString)), SLOT(authSignInError_slt(qint64,qint32,QString)) );
    connect( p->telegram, SIGNAL(authSignUpError(qint64,qint32,QString)), SLOT(authSignUpError_slt(qint64,qint32,QString)) );
    connect( p->telegram, SIGNAL(connected())                           , SIGNAL(connectedChanged())                       );
    connect( p->telegram, SIGNAL(disconnected())                        , SIGNAL(connectedChanged())                       );

    connect( p->telegram, SIGNAL(accountGetWallPapersAnswer(qint64,QList<WallPaper>)),
             SLOT(accountGetWallPapers_slt(qint64,QList<WallPaper>)) );

    connect( p->telegram, SIGNAL(photosUploadProfilePhotoAnswer(qint64,Photo,QList<User>)),
             SLOT(photosUploadProfilePhoto_slt(qint64,Photo,QList<User>)) );
    connect( p->telegram, SIGNAL(photosUpdateProfilePhotoAnswer(qint64,UserProfilePhoto)),
             SLOT(photosUpdateProfilePhoto_slt(qint64,UserProfilePhoto)) );

    connect( p->telegram, SIGNAL(messagesGetDialogsAnswer(qint64,qint32,QList<Dialog>,QList<Message>,QList<Chat>,QList<User>)),
             SLOT(messagesGetDialogs_slt(qint64,qint32,QList<Dialog>,QList<Message>,QList<Chat>,QList<User>)) );
    connect( p->telegram, SIGNAL(messagesGetHistoryAnswer(qint64,qint32,QList<Message>,QList<Chat>,QList<User>)),
             SLOT(messagesGetHistory_slt(qint64,qint32,QList<Message>,QList<Chat>,QList<User>)) );

    connect( p->telegram, SIGNAL(messagesSendMessageAnswer(qint64,qint32,qint32,qint32,qint32,QList<ContactsLink>)),
             SLOT(messagesSendMessage_slt(qint64,qint32,qint32,qint32,qint32,QList<ContactsLink>)) );
    connect( p->telegram, SIGNAL(messagesForwardMessageAnswer(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)),
             SLOT(messagesForwardMessage_slt(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)) );
    connect( p->telegram, SIGNAL(messagesDeleteMessagesAnswer(qint64,QList<qint32>)),
             SLOT(messagesDeleteMessages_slt(qint64,QList<qint32>)) );

    connect( p->telegram, SIGNAL(messagesSendAudioAnswer(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)),
             SLOT(messagesSendAudio_slt(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)) );
    connect( p->telegram, SIGNAL(messagesSendVideoAnswer(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)),
             SLOT(messagesSendVideo_slt(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)) );
    connect( p->telegram, SIGNAL(messagesSendPhotoAnswer(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)),
             SLOT(messagesSendPhoto_slt(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)) );
    connect( p->telegram, SIGNAL(messagesSendDocumentAnswer(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)),
             SLOT(messagesSendDocument_slt(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)) );
    connect( p->telegram, SIGNAL(messagesSendMediaAnswer(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)),
             SLOT(messagesSendMedia_slt(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)) );

    connect( p->telegram, SIGNAL(messagesGetFullChatAnswer(qint64,ChatFull,QList<Chat>,QList<User>)),
             SLOT(messagesGetFullChat_slt(qint64,ChatFull,QList<Chat>,QList<User>)) );
    connect( p->telegram, SIGNAL(messagesCreateChatAnswer(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)),
             SLOT(messagesCreateChat_slt(qint64,Message,QList<Chat>,QList<User>,QList<ContactsLink>,qint32,qint32)) );

    connect( p->telegram, SIGNAL(messagesCreateEncryptedChatAnswer(qint64,qint32,qint64,qint32,qint32,qint32)),
             SLOT(messagesCreateEncryptedChat_slt(qint64,qint32,qint64,qint32,qint32,qint32)) );
    connect( p->telegram, SIGNAL(messagesEncryptedChatRequested(qint32,qint32,qint32,qint64)),
             SLOT(messagesEncryptedChatRequested_slt(qint32,qint32,qint32,qint64)) );
    connect( p->telegram, SIGNAL(messagesEncryptedChatDiscarded(qint32)),
             SLOT(messagesEncryptedChatDiscarded_slt(qint32)) );
    connect( p->telegram, SIGNAL(messagesEncryptedChatCreated(qint32)),
             SLOT(messagesEncryptedChatCreated_slt(qint32)) );
    connect( p->telegram, SIGNAL(messagesSendEncryptedAnswer(qint64,qint32,EncryptedFile)),
             SLOT(messagesSendEncrypted_slt(qint64,qint32,EncryptedFile)) );

    connect( p->telegram, SIGNAL(contactsGetContactsAnswer(qint64,bool,QList<Contact>,QList<User>)),
             SLOT(contactsGetContacts_slt(qint64,bool,QList<Contact>,QList<User>)) );

    connect( p->telegram, SIGNAL(updates(QList<Update>,QList<User>,QList<Chat>,qint32,qint32)),
             SLOT(updates_slt(QList<Update>,QList<User>,QList<Chat>,qint32,qint32)) );
    connect( p->telegram, SIGNAL(updatesCombined(QList<Update>,QList<User>,QList<Chat>,qint32,qint32,qint32)),
             SLOT(updatesCombined_slt(QList<Update>,QList<User>,QList<Chat>,qint32,qint32,qint32)) );
    connect( p->telegram, SIGNAL(updateShort(Update,qint32)),
             SLOT(updateShort_slt(Update,qint32)) );
    connect( p->telegram, SIGNAL(updateShortChatMessage(qint32,qint32,qint32,QString,qint32,qint32,qint32)),
             SLOT(updateShortChatMessage_slt(qint32,qint32,qint32,QString,qint32,qint32,qint32)) );
    connect( p->telegram, SIGNAL(updateShortMessage(qint32,qint32,QString,qint32,qint32,qint32)),
             SLOT(updateShortMessage_slt(qint32,qint32,QString,qint32,qint32,qint32)) );
    connect( p->telegram, SIGNAL(updatesTooLong()),
             SLOT(updatesTooLong_slt()) );
    connect(  p->telegram, SIGNAL(updateDecryptedMessage(qint32,DecryptedMessage,qint32,qint32,EncryptedFile)),
              SLOT(updateDecryptedMessage_slt(qint32,DecryptedMessage,qint32,qint32,EncryptedFile)) );

    connect( p->telegram, SIGNAL(uploadGetFileAnswer(qint64,StorageFileType,qint32,QByteArray,qint32,qint32,qint32)),
             SLOT(uploadGetFile_slt(qint64,StorageFileType,qint32,QByteArray,qint32,qint32,qint32)) );
    connect( p->telegram, SIGNAL(uploadCancelFileAnswer(qint64,bool)),
             SLOT(uploadCancelFile_slt(qint64,bool)) );
    connect( p->telegram, SIGNAL(uploadSendFileAnswer(qint64,qint32,qint32,qint32)),
             SLOT(uploadSendFile_slt(qint64,qint32,qint32,qint32)) );

    emit telegramChanged();

    p->telegram->init();
}

void TelegramQml::authNeeded_slt()
{
    p->authNeeded = true;
    p->authLoggedIn = false;

    emit authNeededChanged();
    emit authLoggedInChanged();
    emit meChanged();

    if( p->telegram && !p->checkphone_req_id )
        p->checkphone_req_id = p->telegram->authCheckPhone();

    p->telegram->accountUpdateStatus(!p->online || p->invisible);
}

void TelegramQml::authLoggedIn_slt()
{
    p->authNeeded = false;
    p->authLoggedIn = true;
    p->phoneChecked = true;

    emit authNeededChanged();
    emit authLoggedInChanged();
    emit authPhoneChecked();
    emit meChanged();

    p->telegram->accountUpdateStatus(!p->online || p->invisible);
}

void TelegramQml::authLogOut_slt(qint64 id, bool ok)
{
    Q_UNUSED(id)
    if(!ok)
        return;

    p->authNeeded = ok;
    p->authLoggedIn = !ok;
    p->logout_req_id = 0;

    emit authNeededChanged();
    emit authLoggedInChanged();
    emit meChanged();
}

void TelegramQml::authSendCode_slt(qint64 id, bool phoneRegistered, qint32 sendCallTimeout)
{
    Q_UNUSED(id)
    p->authNeeded = true;
    p->authLoggedIn = false;

    emit authNeededChanged();
    emit authLoggedInChanged();
    emit authCodeRequested(phoneRegistered, sendCallTimeout );
}

void TelegramQml::authSendCall_slt(qint64 id, bool ok)
{
    Q_UNUSED(id)
    emit authCallRequested(ok);
}

void TelegramQml::authSendInvites_slt(qint64 id, bool ok)
{
    Q_UNUSED(id)
    emit authInvitesSent(ok);
}

void TelegramQml::authCheckPhone_slt(qint64 id, bool phoneRegistered, bool phoneInvited)
{
    Q_UNUSED(id)
    p->phoneRegistered = phoneRegistered;
    p->phoneInvited = phoneInvited;
    p->phoneChecked = true;

    emit authPhoneRegisteredChanged();
    emit authPhoneInvitedChanged();
    emit authPhoneCheckedChanged();

    if( p->telegram )
        p->telegram->authSendCode();
}

void TelegramQml::authSignInError_slt(qint64 id, qint32 errorCode, QString errorText)
{
    Q_UNUSED(id)
    Q_UNUSED(errorCode)

    p->authSignUpError = "";
    p->authSignInError = errorText;
    p->authNeeded = true;
    emit authNeededChanged();
    emit authSignInErrorChanged();
    emit authSignUpErrorChanged();
}

void TelegramQml::authSignUpError_slt(qint64 id, qint32 errorCode, QString errorText)
{
    Q_UNUSED(id)
    Q_UNUSED(errorCode)

    p->authSignUpError = errorText;
    p->authSignInError = "";
    p->authNeeded = true;
    emit authNeededChanged();
    emit authSignInErrorChanged();
    emit authSignUpErrorChanged();
}

void TelegramQml::accountGetWallPapers_slt(qint64 id, const QList<WallPaper> &wallPapers)
{
    Q_UNUSED(id)

    foreach( const WallPaper & wp, wallPapers )
    {
        if( p->wallpapers_map.contains(wp.id()) )
            continue;

        WallPaperObject *obj = new WallPaperObject(wp, this);
        p->wallpapers_map[wp.id()] = obj;

        PhotoSizeObject *sml_size = obj->sizes()->last();
        if( sml_size )
            getFile(sml_size->location());

        PhotoSizeObject *lrg_size = obj->sizes()->first();
        if( lrg_size )
            getFileJustCheck(lrg_size->location());
    }

    emit wallpapersChanged();
}

void TelegramQml::photosUploadProfilePhoto_slt(qint64 id, const Photo &photo, const QList<User> &users)
{
    if( p->profile_upload_id != id )
        return;

    foreach( const User & user, users )
        insertUser(user);

    p->profile_upload_id = 0;
    p->telegram->photosUpdateProfilePhoto(photo.id(), photo.accessHash());
}

void TelegramQml::photosUpdateProfilePhoto_slt(qint64 id, const UserProfilePhoto &userProfilePhoto)
{
    Q_UNUSED(id)

    UserObject *user = p->users.value(me());
    if(user)
        *(user->photo()) = userProfilePhoto;
}

void TelegramQml::contactsGetContacts_slt(qint64 id, bool modified, const QList<Contact> &contacts, const QList<User> &users)
{
    Q_UNUSED(id)
    Q_UNUSED(modified)

    foreach( const User & user, users )
        insertUser(user);
    foreach( const Contact & contact, contacts )
        insertContact(contact);
}

void TelegramQml::messagesSendMessage_slt(qint64 id, qint32 msgId, qint32 date, qint32 pts, qint32 seq, const QList<ContactsLink> &links)
{
    Q_UNUSED(pts)
    Q_UNUSED(seq)
    Q_UNUSED(links)

    if( !p->pend_messages.contains(id) )
        return;

    MessageObject *msgObj = p->pend_messages.take(id);
    msgObj->setSent(true);

    qint64 old_msgId = msgObj->id();

    Peer peer(static_cast<Peer::PeerType>(msgObj->toId()->classType()));
    peer.setChatId(msgObj->toId()->chatId());
    peer.setUserId(msgObj->toId()->userId());

    Message msg(Message::typeMessage);
    msg.setFromId(msgObj->fromId());
    msg.setId(msgId);
    msg.setDate(date);
    msg.setOut(msgObj->out());
    msg.setToId(peer);
    msg.setUnread(msgObj->unread());
    msg.setMessage(msgObj->message());

    qint64 did = msg.toId().chatId();
    if( !did )
        did = msg.out()? msg.toId().userId() : msg.fromId();

    p->garbages.insert( p->messages.take(old_msgId) );
    p->messages_list[did].removeAll(old_msgId);

    startGarbageChecker();
    insertMessage(msg);
    timerUpdateDialogs(3000);
}

void TelegramQml::messagesForwardMessage_slt(qint64 id, const Message &message, const QList<Chat> &chats, const QList<User> &users, const QList<ContactsLink> &links, qint32 pts, qint32 seq)
{
    Q_UNUSED(id)
    Q_UNUSED(links)
    Q_UNUSED(pts)
    Q_UNUSED(seq)

    foreach( const Chat & chat, chats )
        insertChat(chat);
    foreach( const User & user, users )
        insertUser(user);

    insertMessage(message);
}

void TelegramQml::messagesDeleteMessages_slt(qint64 id, const QList<qint32> &deletedMsgIds)
{
    Q_UNUSED(id)
    foreach( qint32 msgId, deletedMsgIds )
    {
        qint64 dId = messageDialogId(msgId);

        p->garbages.insert( p->messages.take(msgId) );
        p->messages_list[dId].removeAll(msgId);
        p->database->deleteMessage(msgId);

        startGarbageChecker();
    }

    emit messagesChanged(false);
    timerUpdateDialogs(3000);
}

void TelegramQml::messagesSendMedia_slt(qint64 id, const Message &message, const QList<Chat> &chats, const QList<User> &users, const QList<ContactsLink> &links, qint32 pts, qint32 seq)
{
    Q_UNUSED(links)
    Q_UNUSED(pts)
    Q_UNUSED(seq)

    foreach( const Chat & chat, chats )
        insertChat(chat);
    foreach( const User & user, users )
        insertUser(user);

    MessageObject *uplMsg = p->uploads.value(id);
    qint64 old_msgId = uplMsg->id();
    qint64 did = uplMsg->toId()->chatId();
    if( !did )
        did = uplMsg->out()? uplMsg->toId()->userId() : uplMsg->fromId();

    p->garbages.insert( p->messages.take(old_msgId) );
    p->messages_list[did].removeAll(old_msgId);

    startGarbageChecker();
    insertMessage(message);
    timerUpdateDialogs(3000);
}

void TelegramQml::messagesSendPhoto_slt(qint64 id, const Message &message, const QList<Chat> &chats, const QList<User> &users, const QList<ContactsLink> &links, qint32 pts, qint32 seq)
{
    Q_UNUSED(links)
    Q_UNUSED(pts)
    Q_UNUSED(seq)

    foreach( const Chat & chat, chats )
        insertChat(chat);
    foreach( const User & user, users )
        insertUser(user);

    MessageObject *uplMsg = p->uploads.value(id);
    qint64 old_msgId = uplMsg->id();
    qint64 did = uplMsg->toId()->chatId();
    if( !did )
        did = uplMsg->out()? uplMsg->toId()->userId() : uplMsg->fromId();

    p->garbages.insert( p->messages.take(old_msgId) );
    p->messages_list[did].removeAll(old_msgId);

    startGarbageChecker();
    insertMessage(message);
    timerUpdateDialogs(3000);
}

void TelegramQml::messagesSendVideo_slt(qint64 id, const Message &message, const QList<Chat> &chats, const QList<User> &users, const QList<ContactsLink> &links, qint32 pts, qint32 seq)
{
    Q_UNUSED(links)
    Q_UNUSED(pts)
    Q_UNUSED(seq)

    foreach( const Chat & chat, chats )
        insertChat(chat);
    foreach( const User & user, users )
        insertUser(user);

    MessageObject *uplMsg = p->uploads.value(id);
    qint64 old_msgId = uplMsg->id();
    qint64 did = uplMsg->toId()->chatId();
    if( !did )
        did = uplMsg->out()? uplMsg->toId()->userId() : uplMsg->fromId();

    p->garbages.insert( p->messages.take(old_msgId) );
    p->messages_list[did].removeAll(old_msgId);

    startGarbageChecker();
    insertMessage(message);
    timerUpdateDialogs(3000);
}

void TelegramQml::messagesSendAudio_slt(qint64 id, const Message &message, const QList<Chat> &chats, const QList<User> &users, const QList<ContactsLink> &links, qint32 pts, qint32 seq)
{
    Q_UNUSED(links)
    Q_UNUSED(pts)
    Q_UNUSED(seq)

    foreach( const Chat & chat, chats )
        insertChat(chat);
    foreach( const User & user, users )
        insertUser(user);

    MessageObject *uplMsg = p->uploads.value(id);
    qint64 old_msgId = uplMsg->id();
    qint64 did = uplMsg->toId()->chatId();
    if( !did )
        did = uplMsg->out()? uplMsg->toId()->userId() : uplMsg->fromId();

    p->garbages.insert( p->messages.take(old_msgId) );
    p->messages_list[did].removeAll(old_msgId);

    startGarbageChecker();
    insertMessage(message);
    timerUpdateDialogs(3000);
}

void TelegramQml::messagesSendDocument_slt(qint64 id, const Message &message, const QList<Chat> &chats, const QList<User> &users, const QList<ContactsLink> &links, qint32 pts, qint32 seq)
{
    Q_UNUSED(links)
    Q_UNUSED(pts)
    Q_UNUSED(seq)

    foreach( const Chat & chat, chats )
        insertChat(chat);
    foreach( const User & user, users )
        insertUser(user);

    MessageObject *uplMsg = p->uploads.value(id);
    qint64 old_msgId = uplMsg->id();
    qint64 did = uplMsg->toId()->chatId();
    if( !did )
        did = uplMsg->out()? uplMsg->toId()->userId() : uplMsg->fromId();

    p->garbages.insert( p->messages.take(old_msgId) );
    p->messages_list[did].removeAll(old_msgId);

    startGarbageChecker();
    insertMessage(message);
    timerUpdateDialogs(3000);
}

void TelegramQml::messagesGetDialogs_slt(qint64 id, qint32 sliceCount, const QList<Dialog> &dialogs, const QList<Message> &messages, const QList<Chat> &chats, const QList<User> &users)
{
    Q_UNUSED(id)
    Q_UNUSED(sliceCount)

    foreach( const User & u, users )
        insertUser(u);
    foreach( const Chat & c, chats )
        insertChat(c);
    foreach( const Message & m, messages )
        insertMessage(m);

    QSet<qint64> dialogIds;
    foreach( const Dialog & d, dialogs )
    {
        insertDialog(d);
        dialogIds.insert( d.peer().chatId()?d.peer().chatId():d.peer().userId() );
    }

    foreach(DialogObject *dobj, p->dialogs)
    {
        qint64 dId = dobj->peer()->chatId()?dobj->peer()->chatId():dobj->peer()->userId();
        if(dialogIds.contains(dId))
            continue;
        if(dobj->encrypted())
            continue;

        p->dialogs.remove(dId);
        p->garbages.insert(dobj);
        p->database->deleteDialog(dId);

        startGarbageChecker();
    }

    emit dialogsChanged(false);
    refreshSecretChats();
}

void TelegramQml::messagesGetHistory_slt(qint64 id, qint32 sliceCount, const QList<Message> &messages, const QList<Chat> &chats, const QList<User> &users)
{
    Q_UNUSED(id)
    Q_UNUSED(sliceCount)

    foreach( const User & u, users )
        insertUser(u);
    foreach( const Chat & c, chats )
        insertChat(c);
    foreach( const Message & m, messages )
        insertMessage(m);

    emit messagesChanged(false);
}

void TelegramQml::messagesGetFullChat_slt(qint64 id, const ChatFull &chatFull, const QList<Chat> &chats, const QList<User> &users)
{
    Q_UNUSED(id)
    foreach( const User & u, users )
        insertUser(u);
    foreach( const Chat & c, chats )
        insertChat(c);

    ChatFullObject *obj = p->chatfulls.value(chatFull.id());
    if( !obj )
    {
        obj = new ChatFullObject(chatFull, this);
        p->chatfulls.insert(chatFull.id(), obj);
    }
    else
        *obj = chatFull;

    emit chatFullsChanged();
}

void TelegramQml::messagesCreateChat_slt(qint64 id, const Message &message, const QList<Chat> &chats, const QList<User> &users, const QList<ContactsLink> &links, qint32 pts, qint32 seq)
{
    Q_UNUSED(id)
    Q_UNUSED(links)
    Q_UNUSED(pts)
    Q_UNUSED(seq)

    foreach( const User & u, users )
        insertUser(u);
    foreach( const Chat & c, chats )
        insertChat(c);

    insertMessage(message);
    timerUpdateDialogs(500);
}

void TelegramQml::messagesCreateEncryptedChat_slt(qint64 id, qint32 chatId, qint64 accessHash, qint32 date, qint32 adminId, qint32 participantId)
{
    Q_UNUSED(id)
    EncryptedChat c(EncryptedChat::typeEncryptedChatWaiting);
    c.setId(chatId);
    c.setAccessHash(accessHash);
    c.setAdminId(adminId);
    c.setParticipantId(participantId);
    c.setDate(date);

    insertEncryptedChat(c);
}

void TelegramQml::messagesEncryptedChatRequested_slt(qint32 chatId, qint32 date, qint32 creatorId, qint64 creatorAccessHash)
{
    EncryptedChat c(EncryptedChat::typeEncryptedChatRequested);
    c.setId(chatId);
    c.setAdminId(creatorId);
    c.setParticipantId(me());
    c.setDate(date);

    if(!p->users.contains(creatorId))
    {
        User u(User::typeUserForeign);
        u.setId(creatorId);
        u.setAccessHash(creatorAccessHash);

        insertUser(u);
    }

    insertEncryptedChat(c);
}

void TelegramQml::messagesEncryptedChatCreated_slt(qint32 chatId)
{
    EncryptedChatObject *c = p->encchats.value(chatId);
    if(!c)
        return;

    c->setClassType(EncryptedChat::typeEncryptedChat);
}

void TelegramQml::messagesEncryptedChatDiscarded_slt(qint32 chatId)
{
    EncryptedChatObject *c = p->encchats.value(chatId);
    if(!c)
        return;

    c->setClassType(EncryptedChat::typeEncryptedChatDiscarded);
}

void TelegramQml::messagesSendEncrypted_slt(qint64 id, qint32 date, const EncryptedFile &encryptedFile)
{
    Q_UNUSED(encryptedFile)
    if( !p->pend_messages.contains(id) )
        return;

    MessageObject *msgObj = p->pend_messages.take(id);
    msgObj->setSent(true);

    qint64 old_msgId = msgObj->id();

    Peer peer(static_cast<Peer::PeerType>(msgObj->toId()->classType()));
    peer.setChatId(msgObj->toId()->chatId());
    peer.setUserId(msgObj->toId()->userId());

    Message msg(Message::typeMessage);
    msg.setFromId(msgObj->fromId());
    msg.setId(date);
    msg.setDate(date);
    msg.setOut(msgObj->out());
    msg.setToId(peer);
    msg.setUnread(msgObj->unread());
    msg.setMessage(msgObj->message());

    qint64 did = msg.toId().chatId();
    if( !did )
        did = msg.out()? msg.toId().userId() : msg.fromId();

    p->garbages.insert( p->messages.take(old_msgId) );
    p->messages_list[did].removeAll(old_msgId);

    startGarbageChecker();
    insertMessage(msg);
    timerUpdateDialogs(3000);
}

void TelegramQml::error(qint64 id, qint32 errorCode, QString errorText)
{
    Q_UNUSED(id)
    Q_UNUSED(errorCode)
    p->error = errorText;
    emit errorChanged();
}

void TelegramQml::updatesTooLong_slt()
{
    timerUpdateDialogs();
}

void TelegramQml::updateShortMessage_slt(qint32 id, qint32 fromId, QString message, qint32 pts, qint32 date, qint32 seq)
{
    Q_UNUSED(pts)
    Q_UNUSED(seq)

    Peer to_peer(Peer::typePeerUser);
    to_peer.setUserId(p->telegram->ourId());

    Message msg(Message::typeMessage);
    msg.setId(id);
    msg.setFromId(fromId);
    msg.setMessage(message);
    msg.setDate(date);
    msg.setOut(false);
    msg.setToId(to_peer);

    insertMessage(msg);
    if( p->dialogs.contains(fromId) )
    {
        DialogObject *dlg_o = p->dialogs.value(fromId);
        dlg_o->setTopMessage(id);
        dlg_o->setUnreadCount( dlg_o->unreadCount()+1 );
    }
    else
    {
        Peer fr_peer(Peer::typePeerUser);
        fr_peer.setUserId(fromId);

        Dialog dlg;
        dlg.setPeer(fr_peer);
        dlg.setTopMessage(id);
        dlg.setUnreadCount(1);

        insertDialog(dlg);
    }

    timerUpdateDialogs(3000);

    emit incomingMessage( p->messages.value(msg.id()) );
}

void TelegramQml::updateShortChatMessage_slt(qint32 id, qint32 fromId, qint32 chatId, QString message, qint32 pts, qint32 date, qint32 seq)
{
    Q_UNUSED(pts)
    Q_UNUSED(seq)

    Peer to_peer(Peer::typePeerChat);
    to_peer.setChatId(chatId);

    Message msg(Message::typeMessage);
    msg.setId(id);
    msg.setFromId(fromId);
    msg.setMessage(message);
    msg.setDate(date);
    msg.setOut(false);
    msg.setToId(to_peer);

    insertMessage(msg);
    if( p->dialogs.contains(chatId) )
    {
        DialogObject *dlg_o = p->dialogs.value(chatId);
        dlg_o->setTopMessage(id);
        dlg_o->setUnreadCount( dlg_o->unreadCount()+1 );
    }
    else
    {
        Dialog dlg;
        dlg.setPeer(to_peer);
        dlg.setTopMessage(id);
        dlg.setUnreadCount(1);

        insertDialog(dlg);
    }

    timerUpdateDialogs(3000);

    emit incomingMessage( p->messages.value(msg.id()) );
}

void TelegramQml::updateShort_slt(const Update &update, qint32 date)
{
    Q_UNUSED(date)
    insertUpdate(update);
}

void TelegramQml::updatesCombined_slt(const QList<Update> & updates, const QList<User> & users, const QList<Chat> & chats, qint32 date, qint32 seqStart, qint32 seq)
{
    Q_UNUSED(date)
    Q_UNUSED(seq)
    Q_UNUSED(seqStart)
    foreach( const Update & u, updates )
        insertUpdate(u);
    foreach( const User & u, users )
        insertUser(u);
    foreach( const Chat & c, chats )
        insertChat(c);
}

void TelegramQml::updates_slt(const QList<Update> & updates, const QList<User> & users, const QList<Chat> & chats, qint32 date, qint32 seq)
{
    Q_UNUSED(date)
    Q_UNUSED(seq)
    foreach( const Update & u, updates )
        insertUpdate(u);
    foreach( const User & u, users )
        insertUser(u);
    foreach( const Chat & c, chats )
        insertChat(c);
}

void TelegramQml::updateDecryptedMessage_slt(qint32 chatId, const DecryptedMessage &m, qint32 date, qint32 qts, const EncryptedFile &attachment)
{
    Q_UNUSED(qts)
    Q_UNUSED(attachment)

    EncryptedChatObject *chat = p->encchats.value(chatId);
    if(!chat)
        return;

    Peer peer(Peer::typePeerChat);
    peer.setChatId(chatId);

    Message msg(Message::typeMessage);
    msg.setToId(peer);
    msg.setMessage(m.message());
    msg.setDate(date);
    msg.setId(date);
    msg.setOut(false);
    msg.setFromId(chat->adminId()==me()?chat->participantId():chat->adminId());

    insertMessage(msg, true);
}

void TelegramQml::uploadGetFile_slt(qint64 id, const StorageFileType &type, qint32 mtime, const QByteArray & bytes, qint32 partId, qint32 downloaded, qint32 total)
{
    FileLocationObject *obj = p->downloads.value(id);
    if( !obj )
        return;

    Q_UNUSED(type)
    const QString & download_file = fileLocation(obj);

    DownloadObject *download = obj->download();
    download->setMtime(mtime);
    download->setPartId(partId);
    download->setTotal(total);
    download->setDownloaded(downloaded);

    if( !download->file()->isOpen() )
    {
        download->file()->setFileName(download_file);
        if( !download->file()->open(QFile::WriteOnly) )
            return;
    }

    download->file()->write(bytes);

    if( downloaded >= total )
    {
        download->file()->flush();
        download->file()->close();

        const QMimeType & t = p->mime_db.mimeTypeForFile(download_file);
        const QStringList & suffixes = t.suffixes();
        if( !suffixes.isEmpty() )
        {
            QString sfx = suffixes.first();
            if(!obj->fileName().isEmpty())
            {
                QFileInfo finfo(obj->fileName());
                if(!finfo.suffix().isEmpty())
                    sfx.clear();
            }

            if(!sfx.isEmpty())
                sfx = "."+sfx;

            QFile::rename(download_file, download_file+sfx);
            download->setLocation("file://" + download_file+sfx);
        }
        else
            download->setLocation("file://" + download_file);

        p->downloads.remove(id);
    }
}

void TelegramQml::uploadSendFile_slt(qint64 fileId, qint32 partId, qint32 uploaded, qint32 totalSize)
{
    MessageObject *msgObj = p->uploads.value(fileId);
    if(!msgObj)
        return;

    UploadObject *upload = msgObj->upload();
    upload->setPartId(partId);
    upload->setUploaded(uploaded);
    upload->setTotalSize(totalSize);
}

void TelegramQml::uploadCancelFile_slt(qint64 fileId, bool cancelled)
{
    if(!cancelled)
        return;

    if( p->uploads.contains(fileId) )
    {
        MessageObject *msgObj = p->uploads.take(fileId);
        qint64 msgId = msgObj->id();
        qint64 dId = messageDialogId(msgId);

        p->garbages.insert( p->messages.take(msgId) );
        p->messages_list[dId].removeAll(msgId);

        startGarbageChecker();
        emit messagesChanged(false);
    }
    else
    if( p->downloads.contains(fileId) )
    {
        FileLocationObject *locObj = p->downloads.take(fileId);
        locObj->download()->setLocation(QString());
        locObj->download()->setFileId(0);
        locObj->download()->setMtime(0);
        locObj->download()->setPartId(0);
        locObj->download()->setTotal(0);
        locObj->download()->setDownloaded(0);
        locObj->download()->file()->close();
        locObj->download()->file()->remove();
    }
}

void TelegramQml::insertDialog(const Dialog &d, bool encrypted, bool fromDb)
{
    qint32 did = d.peer().classType()==Peer::typePeerChat? d.peer().chatId() : d.peer().userId();
    DialogObject *obj = p->dialogs.value(did);
    if( !obj )
    {
        obj = new DialogObject(d, this);
        obj->setEncrypted(encrypted);

        p->dialogs.insert(did, obj);

        connect( obj, SIGNAL(unreadCountChanged()), SLOT(refreshUnreadCount()) );
    }
    else
    if(fromDb)
        return;
    else
    {
        *obj = d;
        obj->setEncrypted(encrypted);
    }

    p->dialogs_list = p->dialogs.keys();

    telegramp_qml_tmp = p;
    qStableSort( p->dialogs_list.begin(), p->dialogs_list.end(), checkDialogLessThan );

    emit dialogsChanged(fromDb);

    refreshUnreadCount();

    if(!fromDb)
        p->database->insertDialog(d, encrypted);
}

void TelegramQml::insertMessage(const Message &m, bool encrypted, bool fromDb, bool tempMsg)
{
    MessageObject *obj = p->messages.value(m.id());
    if( !obj )
    {
        obj = new MessageObject(m, this);
        obj->setEncrypted(encrypted);

        p->messages.insert(m.id(), obj);

        qint64 did = m.toId().chatId();
        if( !did )
            did = m.out()? m.toId().userId() : m.fromId();

        QList<qint64> list = p->messages_list.value(did);

        list << m.id();

        telegramp_qml_tmp = p;
        qStableSort( list.begin(), list.end(), checkMessageLessThan );

        p->messages_list[did] = list;
    }
    else
    if(fromDb && !encrypted)
        return;
    else
    {
        *obj = m;
        obj->setEncrypted(encrypted);
    }

    emit messagesChanged(fromDb && !encrypted);

    if(!fromDb && !tempMsg)
        p->database->insertMessage(m);
    if(encrypted)
        updateEncryptedTopMessage(m);
}

void TelegramQml::insertUser(const User &u, bool fromDb)
{
    UserObject *obj = p->users.value(u.id());
    if( !obj )
    {
        obj = new UserObject(u, this);
        p->users.insert(u.id(), obj);

        getFile(obj->photo()->photoSmall());
    }
    else
    if(fromDb)
        return;
    else
        *obj = u;

    if(!fromDb)
        p->database->insertUser(u);
}

void TelegramQml::insertChat(const Chat &c, bool fromDb)
{
    ChatObject *obj = p->chats.value(c.id());
    if( !obj )
    {
        obj = new ChatObject(c, this);
        p->chats.insert(c.id(), obj);

        getFile(obj->photo()->photoSmall());
    }
    else
    if(fromDb)
        return;
    else
        *obj = c;

    if(!fromDb)
        p->database->insertChat(c);
}

void TelegramQml::insertUpdate(const Update &update)
{
    UserObject *user = p->users.value(update.userId());
    ChatObject *chat = p->chats.value(update.chatId());

    switch( static_cast<int>(update.classType()) )
    {
    case Update::typeUpdateUserStatus:
        if( user )
            *(user->status()) = update.status();
        break;

    case Update::typeUpdateNotifySettings:
        break;

    case Update::typeUpdateMessageID:
        break;

    case Update::typeUpdateChatUserTyping:
    {
        DialogObject *dlg = p->dialogs.value(chat->id());
        if( !dlg )
            return;
        if( !user )
            return;

        const QString & id_str = QString::number(user->id());
        const QPair<qint64,qint64> & timer_pair = QPair<qint64,qint64>(chat->id(), user->id());
        QStringList tusers = dlg->typingUsers();
        if( tusers.contains(id_str) )
        {
            const int timer_id = p->typing_timers.key(timer_pair);
            killTimer(timer_id);
            p->typing_timers.remove(timer_id);
        }
        else
        {
            tusers << id_str;
            dlg->setTypingUsers( tusers );
        }

        int timer_id = startTimer(5000);
        p->typing_timers.insert(timer_id, timer_pair);
    }
        break;

    case Update::typeUpdateActivation:
        break;

    case Update::typeUpdateRestoreMessages:
        break;

    case Update::typeUpdateEncryption:
        break;

    case Update::typeUpdateUserName:
        if( user )
        {
            user->setFirstName(update.firstName());
            user->setLastName(update.lastName());
        }
        timerUpdateDialogs();
        break;

    case Update::typeUpdateUserBlocked:
        break;

    case Update::typeUpdateNewMessage:
        insertMessage(update.message(), false, false, true);
        timerUpdateDialogs(3000);
        break;

    case Update::typeUpdateContactLink:
        break;

    case Update::typeUpdateChatParticipantDelete:
        if(chat)
            chat->setParticipantsCount( chat->participantsCount()-1 );
        break;

    case Update::typeUpdateNewAuthorization:
        break;

    case Update::typeUpdateChatParticipantAdd:
        if(chat)
            chat->setParticipantsCount( chat->participantsCount()+1 );
        break;

    case Update::typeUpdateDcOptions:
        break;

    case Update::typeUpdateDeleteMessages:
    {
        quint64 msgId = update.message().id();
        MessageObject *msg = p->messages.take(msgId);
        if( msg )
            msg->deleteLater();
        timerUpdateDialogs();
    }
        break;

    case Update::typeUpdateUserTyping:
    {
        if(!user)
            return;
        DialogObject *dlg = p->dialogs.value(user->id());
        if( !dlg )
            return;

        const QString & id_str = QString::number(user->id());
        const QPair<qint64,qint64> & timer_pair = QPair<qint64,qint64>(user->id(), user->id());
        QStringList tusers = dlg->typingUsers();
        if( tusers.contains(id_str) )
        {
            const int timer_id = p->typing_timers.key(timer_pair);
            killTimer(timer_id);
            p->typing_timers.remove(timer_id);
        }
        else
        {
            tusers << id_str;
            dlg->setTypingUsers( tusers );
        }

        int timer_id = startTimer(5000);
        p->typing_timers.insert(timer_id, timer_pair);
    }
        break;

    case Update::typeUpdateEncryptedChatTyping:
    {
        DialogObject *dlg = p->dialogs.value(update.chat().id());
        if( !dlg )
            return;

        qint64 userId = update.chat().adminId()==me()? update.chat().participantId() : update.chat().adminId();

        const QString & id_str = QString::number(userId);
        const QPair<qint64,qint64> & timer_pair = QPair<qint64,qint64>(userId, userId);
        QStringList tusers = dlg->typingUsers();
        if( tusers.contains(id_str) )
        {
            const int timer_id = p->typing_timers.key(timer_pair);
            killTimer(timer_id);
            p->typing_timers.remove(timer_id);
        }
        else
        {
            tusers << id_str;
            dlg->setTypingUsers( tusers );
        }

        int timer_id = startTimer(5000);
        p->typing_timers.insert(timer_id, timer_pair);
    }
        break;

    case Update::typeUpdateReadMessages:
    {
        const QList<qint32> & msgIds = update.messages();
        foreach( qint32 msgId, msgIds )
            if( p->messages.contains(msgId) )
                p->messages.value(msgId)->setUnread(false);
    }
        break;

    case Update::typeUpdateUserPhoto:
        if( user )
            *(user->photo()) = update.photo();
        timerUpdateDialogs();
        break;

    case Update::typeUpdateContactRegistered:
        timerUpdateDialogs();
        break;

    case Update::typeUpdateNewEncryptedMessage:
        insertEncryptedMessage(update.encryptedMessage());
        break;

    case Update::typeUpdateEncryptedMessagesRead:
    {
        MessageObject *msg = p->messages.value(update.encryptedMessage().file().id());
        if(!msg)
            return;

        msg->setUnread(false);
    }
        break;

    case Update::typeUpdateChatParticipants:
        timerUpdateDialogs();
        break;
    }
}

void TelegramQml::insertContact(const Contact &c)
{
    ContactObject *obj = p->contacts.value(c.userId());
    if( !obj )
    {
        obj = new ContactObject(c, this);
        p->contacts.insert(c.userId(), obj);
    }
    else
        *obj = c;

    emit contactsChanged();
}

void TelegramQml::insertEncryptedMessage(const EncryptedMessage &e)
{
    EncryptedMessageObject *obj = p->encmessages.value(e.file().id());
    if( !obj )
    {
        obj = new EncryptedMessageObject(e, this);
        p->encmessages.insert(e.file().id(), obj);
    }
    else
        *obj = e;

    emit incomingEncryptedMessage(obj);
}

void TelegramQml::insertEncryptedChat(const EncryptedChat &c)
{
    EncryptedChatObject *obj = p->encchats.value(c.id());
    if( !obj )
    {
        obj = new EncryptedChatObject(c, this);
        p->encchats.insert(c.id(), obj);
    }
    else
        *obj = c;

    emit encryptedChatsChanged();

    Peer peer(Peer::typePeerUser);
    peer.setUserId(c.id());

    Dialog dlg;
    dlg.setPeer(peer);

    DialogObject *dobj = p->dialogs.value(c.id());
    if(dobj)
        dlg.setTopMessage( dobj->topMessage() );

    insertDialog(dlg, true);
}

void TelegramQml::timerEvent(QTimerEvent *e)
{
    if( e->timerId() == p->upd_dialogs_timer )
    {
        if( p->telegram )
            p->telegram->messagesGetDialogs(0,0,1000);

        killTimer(p->upd_dialogs_timer);
        p->upd_dialogs_timer = 0;
    }
    else
    if( e->timerId() == p->garbage_checker_timer )
    {
        foreach( QObject *obj, p->garbages )
            obj->deleteLater();

        p->garbages.clear();
        killTimer(p->garbage_checker_timer);
        p->garbage_checker_timer = 0;
    }
    else
    if( p->typing_timers.contains(e->timerId()) )
    {
        killTimer(e->timerId());

        const QPair<qint64,qint64> & pair = p->typing_timers.take(e->timerId());
        DialogObject *dlg = p->dialogs.value(pair.first);
        if( !dlg )
            return;

        QStringList typings = dlg->typingUsers();
        typings.removeAll(QString::number(pair.second));

        dlg->setTypingUsers(typings);
    }
}

void TelegramQml::startGarbageChecker()
{
    if( p->garbage_checker_timer )
        killTimer(p->garbage_checker_timer);

    p->garbage_checker_timer = startTimer(3000);
}

void TelegramQml::dbUserFounded(const User &user)
{
    insertUser(user, true);
}

void TelegramQml::dbChatFounded(const Chat &chat)
{
    insertChat(chat, true);
}

void TelegramQml::dbDialogFounded(const Dialog &dialog, bool encrypted)
{
    insertDialog(dialog, encrypted, true);
}

void TelegramQml::dbMessageFounded(const Message &message)
{
    bool encrypted = false;
    DialogObject *dlg = p->dialogs.value(message.toId().chatId());
    if(dlg)
        encrypted = dlg->encrypted();

    insertMessage(message, encrypted, true);
}

void TelegramQml::refreshUnreadCount()
{
    int unreadCount = 0;
    foreach( DialogObject *obj, p->dialogs )
        unreadCount += obj->unreadCount();

    if( p->unreadCount == unreadCount )
        return;

    p->unreadCount = unreadCount;
    emit unreadCountChanged();
}

void TelegramQml::refreshSecretChats()
{
    if(!p->tsettings)
        return;

    const QList<SecretChat*> &secrets = p->tsettings->secretChats();
    foreach(SecretChat *sc, secrets)
    {
        EncryptedChat chat(EncryptedChat::typeEncryptedChat);
        chat.setAccessHash(sc->accessHash());
        chat.setAdminId(sc->adminId());
        chat.setDate(sc->date());
        chat.setGAOrB(sc->gAOrB());
        chat.setId(sc->chatId());
        chat.setKeyFingerprint(sc->keyFingerprint());
        chat.setParticipantId(sc->participantId());

        insertEncryptedChat(chat);
    }
}

void TelegramQml::updateEncryptedTopMessage(const Message &message)
{
    qint64 dId = message.toId().chatId();
    if(!dId)
        return;

    DialogObject *dlg = p->dialogs.value(dId);
    if(!dlg)
        return;

    MessageObject *topMessage = p->messages.value(dlg->topMessage());
    if(dlg->topMessage() && !topMessage)
        return;

    qint64 topMsgDate = topMessage? topMessage->date() : 0;
    if(message.date() < topMsgDate)
        return;

    Peer peer(Peer::typePeerUser);
    peer.setUserId(dlg->peer()->userId());

    Dialog dialog;
    dialog.setTopMessage(message.date());
    dialog.setUnreadCount(dlg->unreadCount());
    dialog.setPeer(peer);

    insertDialog(dialog, true, true);
}

qint64 TelegramQml::generateRandomId() const
{
    qint64 randomId;
    Utils::randomBytes(&randomId, 8);
    return randomId;
}

TelegramQml::~TelegramQml()
{
    if( p->telegram )
        delete p->telegram;

    delete p;
}

bool checkDialogLessThan( qint64 a, qint64 b )
{
    DialogObject *ao = telegramp_qml_tmp->dialogs.value(a);
    DialogObject *bo = telegramp_qml_tmp->dialogs.value(b);
    if( !ao )
        return false;
    if( !bo )
        return true;

    MessageObject *am = telegramp_qml_tmp->messages.value(ao->topMessage());
    MessageObject *bm = telegramp_qml_tmp->messages.value(bo->topMessage());
    if(!am || !bm)
        return ao->topMessage() > bo->topMessage();

    return am->date() > bm->date();
}

bool checkMessageLessThan( qint64 a, qint64 b )
{
    return a > b;
}
