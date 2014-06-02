#ifndef TELEGRAM_P_H
#define TELEGRAM_P_H

#ifdef __cplusplus
class QVariant;
#define EXTERNC extern "C"
EXTERNC {
#include "telegram_cli/structers-only.h"
}
#else
#define EXTERNC
#include "telegram_cli/structers-only.h"
#endif

#define WAIT_AND_GET_PHONE_NUMBER 0
#define WAIT_AND_GET_AUTH_CODE    1
#define WAIT_AND_GET_USER_DETAILS 2

EXTERNC void tgStarted();
EXTERNC void qdebug( const char *m );
EXTERNC void qdebugNum( int num );

EXTERNC void contactList_clear();
EXTERNC void contactList_addToBuffer( struct user *u );
EXTERNC void contactList_finished();

EXTERNC void dialogList_clear();
EXTERNC void dialogList_addToBuffer( peer_t *uc, int is_chat, int unread_cnt );
EXTERNC void dialogList_finished();

EXTERNC void msgMarkedAsRead( long long msg_id, int date );
EXTERNC void msgSent( long long msg_id, int date );

EXTERNC void incomingMsg( struct message *msg, struct user *u );
EXTERNC void userIsTyping( int chat_id, int user_id );
EXTERNC void userStatusChanged( peer_t *uc );

EXTERNC void photoFound( int id, long long volume );
EXTERNC void fileLoaded( struct download *d );

EXTERNC void fileUploading( struct send_file *f, long long total, long long uploaded );
EXTERNC void fileDownloading( struct download *d, long long total, long long downloaded );

EXTERNC void registeringStarted();
EXTERNC void registeringFinished();
EXTERNC void registeringInvalidCode();
EXTERNC int waitAndGet( int type, void *pointer );

#ifdef __cplusplus
EXTERNC void waitAndGet_callback( int type, const QVariant & v );
#endif

EXTERNC int qthreadExec();
EXTERNC void qthreadExit(int code);
EXTERNC void qthreadExitRequest(int code);

#endif // TELEGRAM_P_H
