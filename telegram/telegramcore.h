/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef TELEGRAM_H
#define TELEGRAM_H

#include <QThread>
#include <QMap>
#include <QDebug>
#include <QDateTime>

class MessageClass;
class DialogClass;
class UserClass;
class TelegramCorePrivare;
class TelegramCore : public QObject
{
    Q_OBJECT
public:
    TelegramCore(int argc, char **argv, QObject *parent = 0);
    ~TelegramCore();

    int callExec();

public slots:
    void contactList();
    void dialogList();

    void getHistory( const QString & user, int count );

    void sendMessage( const QString & user, const QString & msg );
    void forwardMessage( qint64 msg_id, const QString & user );
    void deleteMessage( qint64 msg_id );
    void restoreMessage( qint64 msg_id );

    void setStatusOnline( bool stt );

    void loadUserInfo( const QString & user );
    void loadChatInfo( const QString & chat );

    void loadPhoto( qint64 msg_id );

    void sendFile( const QString & peer, const QString & file );
    void markRead( const QString & peer );

    void createChat( const QString & title, const QString & user );
    void createSecretChat( const QString & user );
    void renameChat( const QString & title, const QString & new_title );

    void chatAddUser( const QString & chat, const QString & user );
    void chatDelUser( const QString & chat, const QString & user );

    void search( const QString & user, const QString & keyword );
    void globalSearch( const QString & keyword );

    void waitAndGetCallback( int type, const QVariant & var );

    void start();

signals:
    void started();

    void contactListClear();
    void contactFounded( const UserClass & contact );
    void contactListFinished();

    void dialogListClear();
    void dialogFounded( const DialogClass & contact );
    void dialogListFinished();

    void msgMarkedAsRead( qint64 msg_id, const QDateTime & date );
    void msgSent( qint64 msg_id, const QDateTime & date );

    void incomingMsg( const MessageClass & msg );
    void userIsTyping( int chat_id, int user_id );
    void userStatusChanged( int user_id, int status, const QDateTime & when );

    void photoFound( int id, qint64 volume );
    void fileLoaded( qint64 volume, int localId, const QString & path );

    void fileUploading(int user_id, const QString & file, qint64 total, qint64 uploaded );
    void fileDownloading(qint64 volume, qint64 total, qint64 downloaded );

    void registeringStarted();
    void registeringFinished();
    void registeringInvalidCode();

    void waitAndGet( int type );

private:
    void send_command( const QString & cmd );

private:
    TelegramCorePrivare *p;
};

#endif // TELEGRAM_H
