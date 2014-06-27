/*
    This file is part of telegram-client.

    Telegram-client is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    Telegram-client is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this telegram-client.  If not, see <http://www.gnu.org/licenses/>.

    Copyright Vitaly Valtman 2013
*/
#ifndef __STRUCTURES_H__
#define __STRUCTURES_H__

#include <assert.h>
#include "structers-only.h"

int fetch_file_location (struct file_location *loc);
int fetch_user_status (struct user_status *S);
int fetch_user (struct user *U);
struct user *fetch_alloc_user (void);
struct user *fetch_alloc_user_uid (int uid);
struct user *fetch_alloc_user_full (void);
struct chat *fetch_alloc_chat (void);
struct chat *fetch_alloc_chat_full (void);
struct secret_chat *fetch_alloc_encrypted_chat (void);
struct message *fetch_alloc_message (void);
struct message *fetch_alloc_geo_message (void);
struct message *fetch_alloc_message_short (void);
struct message *fetch_alloc_message_short_chat (void);
struct message *fetch_alloc_encrypted_message (void);
void fetch_encrypted_message_file (struct message_media *M);
void fetch_skip_encrypted_message_file (void);
void fetch_encrypted_message_file (struct message_media *M);
void fetch_message_action_encrypted (struct message_action *M);
peer_id_t fetch_peer_id (void);

void fetch_message_media (struct message_media *M);
void fetch_message_media_encrypted (struct message_media *M);
void fetch_message_action (struct message_action *M);
void message_insert_tree (struct message *M);

void free_user (struct user *U);
void free_chat (struct chat *U);

char *create_print_name (peer_id_t id, const char *a1, const char *a2, const char *a3, const char *a4);

int print_stat (char *s, int len);
peer_t *user_chat_get (peer_id_t id);
struct message *message_get (long long id);
void update_message_id (struct message *M, long long id);
void message_insert (struct message *M);
void free_photo (struct photo *P);
void fetch_photo (struct photo *P);
void insert_encrypted_chat (peer_t *P);
void insert_user (peer_t *P);
void insert_chat (peer_t *P);
void fetch_photo (struct photo *P);
void free_photo (struct photo *P);
void message_insert_unsent (struct message *M);
void message_remove_unsent (struct message *M);
void send_all_unsent (void);
void message_remove_tree (struct message *M);
void message_add_peer (struct message *M);
void message_del_peer (struct message *M);
void free_message (struct message *M);
void message_del_use (struct message *M);
void peer_insert_name (peer_t *P);
void peer_delete_name (peer_t *P);
peer_t *peer_lookup_name (const char *s);

#define PEER_USER 1
#define PEER_CHAT 2
#define PEER_GEO_CHAT 3
#define PEER_ENCR_CHAT 4
#define PEER_UNKNOWN 0

#define MK_USER(id) set_peer_id (PEER_USER,id)
#define MK_CHAT(id) set_peer_id (PEER_CHAT,id)
#define MK_GEO_CHAT(id) set_peer_id (PEER_GEO_CHAT,id)
#define MK_ENCR_CHAT(id) set_peer_id (PEER_ENCR_CHAT,id)

static inline int get_peer_type (peer_id_t id) {
  return id.type;
}

static inline int get_peer_id (peer_id_t id) {
  return id.id;
}

static inline peer_id_t set_peer_id (int type, int id) {
  peer_id_t ID;
  ID.id = id;
  ID.type = type;
  return ID;
}

static inline int cmp_peer_id (peer_id_t a, peer_id_t b) {
  return memcmp (&a, &b, sizeof (a));
}

#endif
