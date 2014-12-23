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

#include "telegramchatparticipantsmodel.h"
#include "telegramqml.h"
#include "objects/types.h"

#include <telegram.h>

class TelegramChatParticipantsModelPrivate
{
public:
    TelegramQml *telegram;
    QHash<qint64, ChatParticipantObject*> participants;
    QList<qint64> participants_list;
    QPointer<DialogObject> dialog;
    bool refreshing;
};

TelegramChatParticipantsModel::TelegramChatParticipantsModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new TelegramChatParticipantsModelPrivate;
    p->telegram = 0;
    p->refreshing = false;
}

TelegramQml *TelegramChatParticipantsModel::telegram() const
{
    return p->telegram;
}

void TelegramChatParticipantsModel::setTelegram(TelegramQml *tgo)
{
    TelegramQml *tg = static_cast<TelegramQml*>(tgo);
    if( p->telegram == tg )
        return;

    p->telegram = tg;
    emit telegramChanged();
    if( !p->telegram )
        return;

    connect( p->telegram, SIGNAL(chatFullsChanged()), SLOT(chatFullsChanged()) );
    refresh();
}

DialogObject *TelegramChatParticipantsModel::dialog() const
{
    return p->dialog;
}

void TelegramChatParticipantsModel::setDialog(DialogObject *dlg)
{
    if( p->dialog == dlg )
        return;

    p->dialog = dlg;
    emit dialogChanged();

    beginResetModel();
    p->participants.clear();
    endResetModel();

    if( !p->dialog )
        return;
    if( !p->dialog->peer()->chatId() )
        return;

    refresh();
}

qint64 TelegramChatParticipantsModel::id(const QModelIndex &index) const
{
    int row = index.row();
    return p->participants_list.at(row);
}

int TelegramChatParticipantsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return p->participants.count();
}

QVariant TelegramChatParticipantsModel::data(const QModelIndex &index, int role) const
{
    QVariant res;
    const qint64 key = id(index);
    switch( role )
    {
    case ItemRole:
        res = QVariant::fromValue<ChatParticipantObject*>(p->participants.value(key));
        break;
    }

    return res;
}

QHash<qint32, QByteArray> TelegramChatParticipantsModel::roleNames() const
{
    QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( ItemRole, "item");
    return *res;
}

int TelegramChatParticipantsModel::count() const
{
    return p->participants.count();
}

bool TelegramChatParticipantsModel::refreshing() const
{
    return p->refreshing;
}

void TelegramChatParticipantsModel::refresh()
{
    if( !p->telegram )
        return;
    if( !p->dialog )
        return;
    if( !p->dialog->peer()->chatId() )
        return;

    p->telegram->telegram()->messagesGetFullChat(p->dialog->peer()->chatId());

    p->refreshing = true;
    emit refreshingChanged();
}

void TelegramChatParticipantsModel::chatFullsChanged()
{
    beginResetModel();
    p->participants.clear();
    endResetModel();

    ChatFullObject *chatFull = p->telegram->chatFull(p->dialog->peer()->chatId());
    if( !chatFull )
        return;

    ChatParticipantList *list = chatFull->participants()->participants();
    for( int i=0 ; i<list->count() ; i++ )
    {
        ChatParticipantObject *obj = list->at(i);

        beginInsertRows(QModelIndex(), i, i );
        p->participants.insert( obj->userId(), obj );
        p->participants_list << obj->userId();
        endInsertRows();
    }

    p->refreshing = false;
    emit refreshingChanged();
}

TelegramChatParticipantsModel::~TelegramChatParticipantsModel()
{
    delete p;
}
