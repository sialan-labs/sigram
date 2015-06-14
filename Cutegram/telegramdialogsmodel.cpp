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

#include "telegramdialogsmodel.h"
#include "telegramqml.h"
#include "objects/types.h"
#include "userdata.h"
#include "database.h"

#include <telegram.h>

class TelegramDialogsModelPrivate
{
public:
    TelegramQml *telegram;
    bool initializing;

    int refresh_timer;

    QList<qint64> dialogs;
};

TelegramDialogsModel::TelegramDialogsModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new TelegramDialogsModelPrivate;
    p->telegram = 0;
    p->initializing = false;
    p->refresh_timer = 0;
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

    if( !tg && p->telegram )
    {
        disconnect( p->telegram->userData(), SIGNAL(favoriteChanged(int)) , this, SLOT(userDataChanged()) );
        disconnect( p->telegram->userData(), SIGNAL(valueChanged(QString)), this, SLOT(userDataChanged()) );
    }

    p->telegram = tg;
    p->initializing = tg;
    emit telegramChanged();
    emit initializingChanged();
    if( !p->telegram )
        return;

    connect( p->telegram, SIGNAL(dialogsChanged(bool)), SLOT(dialogsChanged(bool)) );
    connect( p->telegram, SIGNAL(phoneNumberChanged()), SLOT(refreshDatabase()), Qt::QueuedConnection );

    connect( p->telegram->userData(), SIGNAL(favoriteChanged(int)) , this, SLOT(userDataChanged()) );
    connect( p->telegram->userData(), SIGNAL(valueChanged(QString)), this, SLOT(userDataChanged()) );

    refreshDatabase();

    Telegram *tgObject = p->telegram->telegram();
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

    case SectionRole:
        res = p->telegram->userData()->value("love").toLongLong()==key? 2 : (p->telegram->userData()->isFavorited(key)? 1 : 0);
        break;
    }

    return res;
}

QHash<qint32, QByteArray> TelegramDialogsModel::roleNames() const
{
    static QHash<qint32, QByteArray> *res = 0;
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

bool TelegramDialogsModel::initializing() const
{
    return p->initializing;
}

int TelegramDialogsModel::indexOf(DialogObject *dialog)
{
    if(!dialog)
        return -1;

    qint64 dId = dialog->peer()->chatId();
    if(!dId)
        dId = dialog->peer()->userId();

    return p->dialogs.indexOf(dId);
}

DialogObject *TelegramDialogsModel::at(int row)
{
    if(row < 0 || row >= p->dialogs.count())
        return 0;

    return p->telegram->dialog( p->dialogs.at(row) );
}

void TelegramDialogsModel::refreshDatabase()
{
    if(!p->telegram)
        return;

    p->telegram->database()->readFullDialogs();
}

void TelegramDialogsModel::dialogsChanged(bool cachedData)
{
    Q_UNUSED(cachedData)
    if(p->initializing)
    {
        p->initializing = false;
        emit initializingChanged();
    }

    if(p->refresh_timer)
        killTimer(p->refresh_timer);

    p->refresh_timer = startTimer(100);
}

void TelegramDialogsModel::dialogsChanged_priv()
{
    const QList<qint64> & dialogs = fixDialogs(p->telegram->dialogs());

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

    emit countChanged();
}

void TelegramDialogsModel::userDataChanged()
{
    const QList<qint64> & dialogs = fixDialogs(p->telegram->dialogs());

    beginResetModel();
    p->dialogs.clear();
    endResetModel();

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

QList<qint64> TelegramDialogsModel::fixDialogs(QList<qint64> dialogs)
{
    int fav_counts = 0;
    for( int i=0; i<dialogs.count(); i++ )
    {
        qint64 dId = dialogs.at(i);
        if( p->telegram->userData()->isFavorited(dId) )
        {
            dialogs.move(i, fav_counts);
            fav_counts++;
        }
    }

    qint64 love_id = p->telegram->userData()->value("love").toLongLong();
    int love_idx = dialogs.indexOf(love_id);
    if( love_idx != -1 )
        dialogs.move(love_idx, 0);

    return dialogs;
}

void TelegramDialogsModel::timerEvent(QTimerEvent *e)
{
    if(e->timerId() == p->refresh_timer)
    {
        killTimer(p->refresh_timer);
        p->refresh_timer = 0;

        dialogsChanged_priv();
    }

    QAbstractListModel::timerEvent(e);
}

TelegramDialogsModel::~TelegramDialogsModel()
{
    delete p;
}
