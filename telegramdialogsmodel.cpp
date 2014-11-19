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
#include "userdata.h"

#include <telegram.h>

class TelegramDialogsModelPrivate
{
public:
    UserData *userdata;
    TelegramQml *telegram;
    bool intializing;

    QList<qint64> dialogs;
};

TelegramDialogsModel::TelegramDialogsModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new TelegramDialogsModelPrivate;
    p->telegram = 0;
    p->userdata = 0;
    p->intializing = false;
}

TelegramQml *TelegramDialogsModel::telegram() const
{
    return p->telegram;
}

void TelegramDialogsModel::setTelegram(TelegramQml *tgo)
{
    TelegramQml *tg = static_cast<TelegramQml*>(tgo);
    if( p->telegram == tg )
        return;

    p->telegram = tg;
    p->intializing = tg;
    emit telegramChanged();
    emit intializingChanged();
    if( !p->telegram )
    {
        if( p->userdata )
            delete p->userdata;

        p->userdata = 0;
        return;
    }

    connect( p->telegram, SIGNAL(dialogsChanged()), SLOT(dialogsChanged()) );

    Telegram *tgObject = p->telegram->telegram();
    tgObject->messagesGetDialogs(0,0,1000);

    p->userdata = new UserData(p->telegram->phoneNumber(), this);
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

    case SectionRole:
        res = p->userdata->value("love").toLongLong()==key? 2 : (p->userdata->isFavorited(key)? 1 : 0);
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
    res->insert( SectionRole, "section");
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

void TelegramDialogsModel::dialogsChanged()
{
    p->intializing = false;
    emit intializingChanged();

    QList<qint64> dialogs = p->telegram->dialogs();

    for( int i=0 ; i<p->dialogs.count() ; i++ )
    {
        const qint64 dId = p->dialogs.at(i);
        if( dialogs.contains(dId) )
            continue;

        beginRemoveRows(QModelIndex(), i, i);
        p->dialogs.removeAt(i);
        i--;
        endRemoveRows();
    }


    QList<qint64> temp_msgs = dialogs;
    for( int i=0 ; i<temp_msgs.count() ; i++ )
    {
        const qint64 dId = temp_msgs.at(i);
        if( p->dialogs.contains(dId) )
            continue;

        temp_msgs.removeAt(i);
        i--;
    }
    while( p->dialogs != temp_msgs )
        for( int i=0 ; i<p->dialogs.count() ; i++ )
        {
            const qint64 dId = p->dialogs.at(i);
            int nw = temp_msgs.indexOf(dId);
            if( i == nw )
                continue;

            beginMoveRows( QModelIndex(), i, i, QModelIndex(), nw>i?nw+1:nw );
            p->dialogs.move( i, nw );
            endMoveRows();
        }


    for( int i=0 ; i<dialogs.count() ; i++ )
    {
        const qint64 dId = dialogs.at(i);
        if( p->dialogs.contains(dId) )
            continue;

        beginInsertRows(QModelIndex(), i, i );
        p->dialogs.insert( i, dId );
        endInsertRows();
    }
}

TelegramDialogsModel::~TelegramDialogsModel()
{
    delete p;
}
