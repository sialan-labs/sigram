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

#include "telegramuploadsmodel.h"
#include "telegramqml.h"
#include "objects/types.h"

#include <telegram.h>

class TelegramUploadsModelPrivate
{
public:
    TelegramQml *telegram;
    QList<qint64> uploads;
};

TelegramUploadsModel::TelegramUploadsModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new TelegramUploadsModelPrivate;
    p->telegram = 0;
}

TelegramQml *TelegramUploadsModel::telegram() const
{
    return p->telegram;
}

void TelegramUploadsModel::setTelegram(TelegramQml *tgo)
{
    TelegramQml *tg = static_cast<TelegramQml*>(tgo);
    if( p->telegram == tg )
        return;

    p->telegram = tg;
    emit telegramChanged();
    if( !p->telegram )
        return;

    connect( p->telegram, SIGNAL(uploadsChanged()), SLOT(uploadsChanged()) );
}

qint64 TelegramUploadsModel::id(const QModelIndex &index) const
{
    int row = index.row();
    return p->uploads.at(row);
}

int TelegramUploadsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return p->uploads.count();
}

QVariant TelegramUploadsModel::data(const QModelIndex &index, int role) const
{
    QVariant res;
    const qint64 key = id(index);
    switch( role )
    {
    case ItemRole:
        res = QVariant::fromValue<MessageObject*>(p->telegram->upload(key));
        break;
    }

    return res;
}

QHash<qint32, QByteArray> TelegramUploadsModel::roleNames() const
{
    QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( ItemRole, "item");
    return *res;
}

int TelegramUploadsModel::count() const
{
    return p->uploads.count();
}

void TelegramUploadsModel::uploadsChanged()
{
    const QList<qint64> & uploads = p->telegram->uploads();

    beginResetModel();
    p->uploads.clear();
    endResetModel();

    for( int i=0 ; i<uploads.count() ; i++ )
    {
        const qint64 dId = uploads.at(i);
        if( p->uploads.contains(dId) )
            continue;

        beginInsertRows(QModelIndex(), i, i );
        p->uploads.insert( i, dId );
        endInsertRows();
    }
}

TelegramUploadsModel::~TelegramUploadsModel()
{
    delete p;
}
