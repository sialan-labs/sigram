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
#include "telegramqml.h"
#include "objects/types.h"

#include <telegram.h>

class TelegramDialogsModelPrivate
{
public:
    TelegramQml *telegram;
    bool intializing;

    QList<qint64> dialogs;
};

TelegramDialogsModel::TelegramDialogsModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new TelegramDialogsModelPrivate;
    p->telegram = 0;
    p->intializing = false;
}

QObject *TelegramDialogsModel::telegram() const
{
    return p->telegram;
}

void TelegramDialogsModel::setTelegram(QObject *tgo)
{
    TelegramQml *tg = static_cast<TelegramQml*>(tgo);
    if( p->telegram == tg )
        return;

    p->telegram = tg;
    p->intializing = tg;
    emit telegramChanged();
    emit intializingChanged();
    if( !p->telegram )
        return;

    Telegram *tgObject = p->telegram->telegram();

    connect( tgObject, SIGNAL(messagesGetDialogsAnswer(qint64,qint32,QList<Dialog>,QList<Message>,QList<Chat>,QList<User>)),
             SLOT(messagesGetDialogs_slt(qint64,qint32,QList<Dialog>,QList<Message>,QList<Chat>,QList<User>)) );

    tgObject->messagesGetDialogs(0,0,1000);
}

qint64 TelegramDialogsModel::id(const QModelIndex &index) const
{
    int row = index.row();
    return p->dialogs.at(row);
}

int TelegramDialogsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return p->dialogs.count();
}

QVariant TelegramDialogsModel::data(const QModelIndex &index, int role) const
{
    QVariant res;
    const qint64 key = id(index);
    switch( role )
    {
    case ItemRole:
        res = QVariant::fromValue<DialogObject*>(p->telegram->dialog(key));
        break;
    }

    return res;
}

QHash<qint32, QByteArray> TelegramDialogsModel::roleNames() const
{
    QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( ItemRole, "item");
    return *res;
}

int TelegramDialogsModel::count() const
{
    return p->dialogs.count();
}

bool TelegramDialogsModel::intializing() const
{
    return p->intializing;
}

void TelegramDialogsModel::messagesGetDialogs_slt(qint64 id, qint32 sliceCount, const QList<Dialog> &dialogs, const QList<Message> &messages, const QList<Chat> &chats, const QList<User> &users)
{
    Q_UNUSED(id)
    Q_UNUSED(sliceCount)
    Q_UNUSED(users)
    Q_UNUSED(messages)
    Q_UNUSED(chats)

    foreach( const Dialog & d, dialogs )
    {
        qint32 did = d.peer().classType()==Peer::typePeerChat? d.peer().chatId() : d.peer().userId();
        if( p->dialogs.contains(did) )
            continue;

        beginInsertRows(QModelIndex(), count(), count());
        p->dialogs.append(did);
        endInsertRows();
    }
}

TelegramDialogsModel::~TelegramDialogsModel()
{
    delete p;
}
