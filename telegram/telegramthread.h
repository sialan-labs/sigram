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

#ifndef TELEGRAMTHREAD_H
#define TELEGRAMTHREAD_H

#include <QThread>

class MessageClass;
class DialogClass;
class UserClass;
class TelegramThreadPrivate;
class TelegramThread : public QThread
{
    Q_OBJECT
public:
    TelegramThread(int argc, char **argv, QObject *parent = 0);
    ~TelegramThread();

    int callExec();

    const QHash<int,UserClass> & contacts() const;
    const QHash<int,DialogClass> & dialogs() const;
    const QHash<int,QString> & photos() const;

    const QHash<int,QMap<qint64, qint64> > & usersMessages() const;
    const QHash<qint64,MessageClass> & messages() const;
    QSet<qint64> messagesOf(int uid) const;

    int me() const;

public slots:
    void contactList();
    void dialogList();
    void getHistory(int id, int count );

    void sendMessage( int id, const QString & msg );
    void forwardMessage( qint64 msg_id, int user_id );
    void deleteMessage( qint64 msg_id );
    void restoreMessage( qint64 msg_id );

    void loadUserInfo( int userId );
    void loadChatInfo( int chatId );

    void loadPhoto( qint64 msg_id );

    void sendFile( int dId, const QString & file );
    void markRead( int dId );

    void setStatusOnline( bool stt );

    void createChat( const QString & title, int user_id );
    void createSecretChat( int user_id );
    void renameChat( int chat_id, const QString & new_title );

    void chatAddUser( int chat_id, int user_id );
    void chatDelUser( int chat_id, int user_id );

    void addContact( const QString & number, const QString & fname, const QString & lname, bool force );

    void search( int user_id, const QString & keyword );
    void globalSearch( const QString & keyword );

    void waitAndGetCallback( int type, const QVariant & var );

signals:
    void contactsChanged();
    void dialogsChanged();
    void tgStarted();
    void incomingMsg( qint64 msg_id );
    void incomingNewMsg( qint64 msg_id );
    void userIsTyping( int chat_id, int user_id );
    void userStatusChanged( int user_id, int status, const QDateTime & when );

    void userPhotoChanged( int user_id );
    void chatPhotoChanged( int user_id );

    void msgChanged( qint64 msg_id );
    void msgSent( qint64 old_id, qint64 msg_id );

    void fileUploaded( int user_id, const QString & file );
    void fileUploading(int user_id, const QString & file, qreal percent );
    void fileUserUploaded( int user_id );
    void fileUserUploading( int user_id, qreal percent );

    void msgFileDownloaded( qint64 msg_id );
    void msgFileDownloading( qint64 msg_id, qreal percent );

    void messageDeleted( qint64 msg_id );
    void messageRestored( qint64 msg_id );

    void registeringStarted();
    void registeringFinished();
    void registeringInvalidCode();

    void waitAndGet( int type );

protected:
    void run();

private slots:
    void _contactListClear();
    void _contactFounded( const UserClass & contact );
    void _contactListFinished();

    void _dialogListClear();
    void _dialogFounded( const DialogClass & dialog );
    void _dialogListFinished();

    void _msgMarkedAsRead(qint64 msg_id, const QDateTime &date );
    void _msgSent(qint64 msg_id, const QDateTime &date );
    void _incomingMsg( const MessageClass & msg );
    void _userStatusChanged(int user_id, int status, const QDateTime &when );

    void _photoFound( int id, qint64 volume );
    void _fileLoaded( qint64 volume, int localId, const QString & path );

    void _fileUploading(int user_id, const QString & file, qint64 total, qint64 uploaded );
    void _fileDownloading(qint64 volume, qint64 total, qint64 downloaded );

    void _waitAndGet( int type );

private:
    QString normalizePhoto( const QString & path );

private:
    TelegramThreadPrivate *p;
};

#endif // TELEGRAMTHREAD_H
