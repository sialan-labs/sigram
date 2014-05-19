#ifndef TELEGRAM_P_H
#define TELEGRAM_P_H

#ifdef __cplusplus
#define EXTERNC extern "C"
#else
#define EXTERNC
#endif

EXTERNC void tgStarted();
EXTERNC void callSignal();

EXTERNC void contactList_clear();
EXTERNC void contactList_addToBuffer( int user_id, const char *firstname, const char *lastname, long long photo_id, const char *username, const char *phone, int state, int last_time );
EXTERNC void contactList_finished();

EXTERNC void dialogList_clear();
EXTERNC void dialogList_addToBuffer_user( int user_id, const char *firstname, const char *lastname, long long photo_id, const char *username, const char *phone, int state, int last_time, int unread_cnt, int msg_date, const char * last_msg );
EXTERNC void dialogList_addToBuffer_chat( int chat_id, const char *title, int admin, long long photo_id, void *user_list, int user_list_size, int users_num, int date, int unread_cnt, int msg_date, const char * last_msg );
EXTERNC void dialogList_finished();

EXTERNC void msgMarkedAsRead( long long msg_id, int date );
EXTERNC void msgSent( long long msg_id, int date );

EXTERNC void incomingMsg( long long msg_id, int from_id, int to_id, int fwd_id, int fwd_date, int out, int unread, int date, int service, const char *message);
EXTERNC void userIsTyping( int chat_id, int user_id );
EXTERNC void userStatusChanged( int user_id, int status, int when );

EXTERNC void qthreadExec();
EXTERNC void qthreadExit(int code);

#endif // TELEGRAM_P_H
