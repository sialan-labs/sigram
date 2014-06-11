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

#ifndef TELEGRAM_P_H
#define TELEGRAM_P_H

#define WAIT_AND_GET_PHONE_NUMBER 0
#define WAIT_AND_GET_AUTH_CODE    1
#define WAIT_AND_GET_USER_DETAILS 2

#ifdef __cplusplus
class QVariant;
extern "C" {
#endif

#include "telegram_cli/structers-only.h"

void tgStarted();
void qdebug( const char *m );
void qdebugNum( int num );
void debugToFile( const char *m );
void debugNumToFile( double m );
void uSleep(int s);

const char *serverPubPath();

void contactList_clear();
void contactList_addToBuffer( struct user *u );
void contactList_finished();

void dialogList_clear();
void dialogList_addToBuffer( peer_t *uc, int is_chat, int unread_cnt );
void dialogList_finished();

void msgMarkedAsRead( long long msg_id, int date );
void msgSent( long long msg_id, int date );

void incomingMsg( struct message *msg, struct user *u );
void userIsTyping( int chat_id, int user_id );
void userStatusChanged( peer_t *uc );

void photoFound( int id, long long volume );
void fileLoaded( struct download *d );

void fileUploading( struct send_file *f, long long total, long long uploaded );
void fileDownloading( struct download *d, long long total, long long downloaded );

void registeringStarted();
void registeringFinished();
void registeringInvalidCode();
int waitAndGet( int type, void *pointer );

void encryptedChatUpdated( struct secret_chat *e );

#ifdef __cplusplus
void waitAndGet_callback( int type, const QVariant & v );
#endif

int qthreadExec();
void qthreadExit(int code);
void qthreadExitRequest(int code);

#ifdef __cplusplus
}
#endif

#endif // TELEGRAM_P_H
