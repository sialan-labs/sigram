/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

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

#include "sialantools/sialanapplication.h"
#include "telegramqml.h"
#include "userdata.h"
#include "objects/types.h"

#include <telegram.h>
#include <limits>

#include <QPointer>
#include <QTimerEvent>
#include <QDebug>
#include <QHash>
#include <QDateTime>
#include <QMimeDatabase>
#include <QMimeType>

TelegramQmlPrivate *telegramp_qml_tmp = 0;
bool checkDialogLessThan( qint64 a, qint64 b );
bool checkMessageLessThan( qint64 a, qint64 b );

class TelegramQmlPrivate
{
public:
    UserData *userdata;
    Telegram *telegram;

    QString phoneNumber;
    QString configPath;
    QString publicKeyFile;

    bool online;

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

    QHash<qint64,DialogObject*> dialogs;
    QHash<qint64,MessageObject*> messages;
    QHash<qint64,ChatObject*> chats;
    QHash<qint64,UserObject*> users;

    QList<qint64> dialogs_list;
    QHash<qint64, QList<qint64> > messages_list;
    QMap<qint64, WallPaperObject*> wallpapers_map;

    QHash<qint64,MessageObject*> pend_messages;
    QHash<qint64,FileLocationObject*> downloads;
    QHash<qint64,UploadObject*> uploads;

    QHash<int, QPair<qint64,qint64> > typing_timers;
    int upd_dialogs_timer;

    DialogObject *nullDialog;
    MessageObject *nullMessage;
    ChatObject *nullChat;
    UserObject *nullUser;
    FileLocationObject *nullFile;
    WallPaperObject *nullWallpaper;
    UploadObject *nullUpload;

    QMimeDatabase mime_db;

    qint32 msg_send_id_counter;
};

TelegramQml::TelegramQml(QObject *parent) :
    QObject(parent)
{
    p = new TelegramQmlPrivate;
    p->upd_dialogs_timer = 0;
    p->online = false;
    p->msg_send_id_counter = INT_MAX - 100000;

    p->userdata = 0;
    p->telegram = 0;
    p->authNeeded = false;
    p->authLoggedIn = false;
    p->phoneRegistered = false;
    p->phoneInvited = false;
    p->phoneChecked = false;

    p->logout_req_id = 0;
    p->checkphone_req_id = 0;

    p->nullDialog = new DialogObject( Dialog(), this );
    p->nullMessage = new MessageObject(Message(Message::typeMessageEmpty), this);
    p->nullChat = new ChatObject(Chat(Chat::typeChatEmpty), this);
    p->nullUser = new UserObject(User(User::typeUserEmpty), this);
    p->nullFile = new FileLocationObject(FileLocation(FileLocation::typeFileLocationUnavailable), this);
    p->nullWallpaper = new WallPaperObject(WallPaper(WallPaper::typeWallPaperSolid), this);
    p->nullUpload = new UploadObject(this);
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
}

QString TelegramQml::downloadPath() const
{
    return SialanApplication::homePath() + "/" + phoneNumber() + "/downloads";
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
        p->telegram->accountUpdateStatus(!p->online);

    emit onlineChanged();
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
        dId = msg->toId()->userId();

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

UploadObject *TelegramQml::upload(qint64 id) const
{
    UploadObject *res = p->uploads.value(id);
    if( !res )
        res = p->nullUpload;
    return res;
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

QString TelegramQml::fileLocation(FileLocationObject *l)
{
    const QString & dpath = downloadPath();
    const QString & fname = QString("%1_%2").arg(l->volumeId()).arg(l->localId());

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

    DialogObject *dlg = dialog(dId);
    if( !dlg )
        return;

    bool isChat = dlg->peer()->classType()==Peer::typePeerChat;
    InputPeer peer(isChat? InputPeer::typeInputPeerChat : InputPeer::typeInputPeerContact);
    peer.setChatId(dlg->peer()->chatId());
    peer.setUserId(dlg->peer()->userId());

    Peer to_peer(static_cast<Peer::PeerType>(dlg->peer()->classType()));
    to_peer.setChatId(dlg->peer()->chatId());
    to_peer.setUserId(dlg->peer()->userId());

    qint32 msgId = p->msg_send_id_counter;
    p->msg_send_id_counter++;

    Message message(Message::typeMessage);
    message.setId(msgId);
    message.setDate( QDateTime::currentDateTime().toTime_t() );
    message.setFromId( p->telegram->ourId() );
    message.setMessage(msg);
    message.setOut(true);
    message.setToId(to_peer);
    message.setUnread(true);

    qint64 sendId = p->telegram->messagesSendMessage(peer, msg);

    insertMessage(message);

    MessageObject *msgObj = p->messages.value(msgId);
    msgObj->setSent(false);

    p->pend_messages[sendId] = msgObj;

    timerUpdateDialogs();
}

void TelegramQml::sendFile(qint64 dId, const QString &fpath)
{
    QString file = fpath;
    if( file.left(7) == "file://" )
        file = file.mid(7);

    if( !QFileInfo::exists(file) )
        return;
    if( !p->telegram )
        return;

    DialogObject *dlg = dialog(dId);
    if( !dlg )
        return;

    bool isChat = dlg->peer()->classType()==Peer::typePeerChat;
    InputPeer peer(isChat? InputPeer::typeInputPeerChat : InputPeer::typeInputPeerContact);
    peer.setChatId(dlg->peer()->chatId());
    peer.setUserId(dlg->peer()->userId());

    qint64 fileId;
    const QMimeType & t = p->mime_db.mimeTypeForFile(file);
    if( t.name().contains("image/") )
        fileId = p->telegram->messagesSendPhoto(peer, file);
    else
    if( t.name().contains("video/") )
        fileId = p->telegram->messagesSendVideo(peer, file, 0, 0, 0);
    else
    if( t.name().contains("audio/") )
        fileId = p->telegram->messagesSendAudio(peer, file, 0);
    else
        fileId = p->telegram->messagesSendDocument(peer, file);

    UploadObject *upload = new UploadObject(this);
    upload->setFileId(fileId);
    upload->setLocation(file);
    upload->setTotalSize(QFileInfo(file).size());

    p->uploads[fileId] = upload;
    emit uploadsChanged();
}

void TelegramQml::getFile(FileLocationObject *l)
{
    if( !p->telegram )
        return;
    if( l->secret() == 0 )
        return;

    const QString & download_file = fileLocation(l);
    if( QFile::exists(download_file) )
    {
        l->download()->setLocation("file://"+download_file);
        return;
    }

    InputFileLocation input(InputFileLocation::typeInputFileLocation);
    input.setLocalId(l->localId());
    input.setSecret(l->secret());
    input.setVolumeId(l->volumeId());

    qint64 fileId = p->telegram->uploadGetFile(input, 4092, l->dcId());
    p->downloads[fileId] = l;

    l->download()->setFileId(fileId);
}

void TelegramQml::checkFile(FileLocationObject *l)
{
    if( !p->telegram )
        return;
    if( l->secret() == 0 )
        return;

    const QString & download_file = fileLocation(l);
    if( !QFile::exists(download_file) )
        return;

    l->download()->setLocation("file://"+download_file);
}

void TelegramQml::cancelSendGet(qint64 fileId)
{
    if( !p->telegram )
        return;

    p->telegram->uploadCancelFile(fileId);
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

    connect( p->telegram, SIGNAL(accountGetWallPapersAnswer(qint64,QList<WallPaper>)), this
             , SLOT(accountGetWallPapers_slt(qint64,QList<WallPaper>)) );

    connect( p->telegram, SIGNAL(messagesGetDialogsAnswer(qint64,qint32,QList<Dialog>,QList<Message>,QList<Chat>,QList<User>)),
             SLOT(messagesGetDialogs_slt(qint64,qint32,QList<Dialog>,QList<Message>,QList<Chat>,QList<User>)) );
    connect( p->telegram, SIGNAL(messagesGetHistoryAnswer(qint64,qint32,QList<Message>,QList<Chat>,QList<User>)),
             SLOT(messagesGetHistory_slt(qint64,qint32,QList<Message>,QList<Chat>,QList<User>)) );
    connect( p->telegram, SIGNAL(messagesSendMessageAnswer(qint64,qint32,qint32,qint32,qint32,QList<ContactsLink>)),
             SLOT(messagesSendMessage_slt(qint64,qint32,qint32,qint32,qint32,QList<ContactsLink>)) );

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

    connect( p->telegram, SIGNAL(uploadGetFileAnswer(qint64,StorageFileType,qint32,QByteArray,qint32,qint32,qint32)),
             SLOT(uploadGetFile_slt(qint64,StorageFileType,qint32,QByteArray,qint32,qint32,qint32)) );
    connect( p->telegram, SIGNAL(uploadCancelFileAnswer(qint64,bool)), this,
             SLOT(uploadCancelFile_slt(qint64,bool)) );
    connect( p->telegram, SIGNAL(uploadSendFileAnswer(qint64,qint32,qint32,qint32)), this,
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

    p->telegram->accountUpdateStatus(!p->online);
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

    p->telegram->accountUpdateStatus(!p->online);
}

void TelegramQml::authLogOut_slt(qint64 id, bool ok)
{
    Q_UNUSED(id)
    p->authNeeded = ok;
    p->authLoggedIn = !ok;
    p->logout_req_id = 0;

    emit authNeededChanged();
    emit authLoggedInChanged();
    emit meChanged();

    if( p->authLoggedIn )
        p->telegram->accountUpdateStatus(!p->online);
}

void TelegramQml::authSendCode_slt(qint64 id, bool phoneRegistered, qint32 sendCallTimeout)
{
    Q_UNUSED(id)
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
            checkFile(lrg_size->location());
    }

    emit wallpapersChanged();
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

    p->messages.take(old_msgId);
    p->messages_list[did].removeAll(old_msgId);

    insertMessage(msg);
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
    foreach( const Dialog & d, dialogs )
        insertDialog(d);
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
            const QString & sfx = suffixes.first();
            QFile::rename(download_file, download_file+"."+sfx);
            download->setLocation("file://" + download_file+"."+sfx);
        }
        else
            download->setLocation("file://" + download_file);

        p->downloads.remove(id);
    }
}

void TelegramQml::uploadSendFile_slt(qint64 fileId, qint32 partId, qint32 uploaded, qint32 totalSize)
{
    UploadObject *upload = p->uploads.value(fileId);
    if(!upload)
        return;

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

    }
    else
    if( p->downloads.contains(fileId) )
    {

    }
}

void TelegramQml::insertDialog(const Dialog &d)
{
    qint32 did = d.peer().classType()==Peer::typePeerChat? d.peer().chatId() : d.peer().userId();
    DialogObject *obj = p->dialogs.value(did);
    if( !obj )
    {
        obj = new DialogObject(d, this);
        p->dialogs.insert(did, obj);
    }
    else
        *obj = d;

    p->dialogs_list = p->dialogs.keys();

    telegramp_qml_tmp = p;
    qStableSort( p->dialogs_list.begin(), p->dialogs_list.end(), checkDialogLessThan );

    emit dialogsChanged();
}

void TelegramQml::insertMessage(const Message &m)
{
    MessageObject *obj = p->messages.value(m.id());
    if( !obj )
    {
        obj = new MessageObject(m, this);
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
        *obj = m;

    emit messagesChanged();
}

void TelegramQml::insertUser(const User &u)
{
    UserObject *obj = p->users.value(u.id());
    if( !obj )
    {
        obj = new UserObject(u, this);
        p->users.insert(u.id(), obj);

        getFile(obj->photo()->photoSmall());
    }
    else
        *obj = u;
}

void TelegramQml::insertChat(const Chat &c)
{
    ChatObject *obj = p->chats.value(c.id());
    if( !obj )
    {
        obj = new ChatObject(c, this);
        p->chats.insert(c.id(), obj);

        getFile(obj->photo()->photoSmall());
    }
    else
        *obj = c;
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
        insertMessage(update.message());
        timerUpdateDialogs(3000);
        break;

    case Update::typeUpdateContactLink:
        break;

    case Update::typeUpdateChatParticipantDelete:
        chat->setParticipantsCount( chat->participantsCount()-1 );
        break;

    case Update::typeUpdateNewAuthorization:
        break;

    case Update::typeUpdateChatParticipantAdd:
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
        break;

    case Update::typeUpdateContactRegistered:
        break;

    case Update::typeUpdateNewEncryptedMessage:
        break;

    case Update::typeUpdateEncryptedMessagesRead:
        break;

    case Update::typeUpdateChatParticipants:
        timerUpdateDialogs();
        break;
    }
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

    return ao->topMessage() > bo->topMessage();
}

bool checkMessageLessThan( qint64 a, qint64 b )
{
    return a > b;
}
