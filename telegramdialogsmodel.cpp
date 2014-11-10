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

#include "telegramdialogsmodel.h"
#include "objects/types.h"

#include <telegram.h>

class TelegramDialogsModelPrivate
{
public:
    Telegram *telegram;
    bool intializing;
};

TelegramDialogsModel::TelegramDialogsModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new TelegramDialogsModelPrivate;
    p->telegram = 0;
    p->intializing = false;
}

Telegram *TelegramDialogsModel::telegram() const
{
    return p->telegram;
}

void TelegramDialogsModel::setTelegram(Telegram *tg)
{
    if( p->telegram == tg )
        return;

    p->telegram = tg;
    p->intializing = tg;
    emit telegramChanged();
    emit intializingChanged();
    if( !p->telegram )
        return;

    p->telegram->messagesGetDialogs();
}

QString TelegramDialogsModel::id(const QModelIndex &index) const
{

}

int TelegramDialogsModel::rowCount(const QModelIndex &parent) const
{

}

QVariant TelegramDialogsModel::data(const QModelIndex &index, int role) const
{

}

bool TelegramDialogsModel::setData(const QModelIndex &index, const QVariant &value, int role)
{

}

QHash<qint32, QByteArray> TelegramDialogsModel::roleNames() const
{
    QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
//    res->insert( NumberRole, "number");
    return *res;
}

Qt::ItemFlags TelegramDialogsModel::flags(const QModelIndex &index) const
{
    Q_UNUSED(index)
    return Qt::ItemIsEditable | Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

int TelegramDialogsModel::count() const
{

}

bool TelegramDialogsModel::intializing() const
{
    return p->intializing;
}

void TelegramDialogsModel::messagesGetDialogsAnswer(qint64 id, qint32 sliceCount, const QList<Dialog> &dialogs, const QList<Message> &messages, const QList<Chat> &chats, const QList<User> &users)
{
    Q_UNUSED(id)
    for( int i=0; i<sliceCount; i++ )
    {
        const Dialog & dialog = dialogs.at(i);
        const Message & message = messages.at(i);
        const Chat & chat = chats.at(i);
        const User & user = users.at(i);

        DialogObject *dialog_o = new DialogObject(dialog, this);
        MessageObject *message_o = new MessageObject(message, this);
        ChatObject *chat_o = new ChatObject(chat, this);
        UserObject *user_o = new UserObject(user, this);
    }
}

TelegramDialogsModel::~TelegramDialogsModel()
{
    delete p;
}
