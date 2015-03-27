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

#include "chatparticipantlist.h"
#include "objects/types.h"

class ChatParticipantListPrivate
{
public:
    QList<ChatParticipantObject*> list;
};

ChatParticipantList::ChatParticipantList(QObject *parent) :
    QObject(parent)
{
    p = new ChatParticipantListPrivate;
}

ChatParticipantList::ChatParticipantList(const QList<ChatParticipant> &another, QObject *parent) :
    QObject(parent)
{
    p = new ChatParticipantListPrivate;
    operator =(another);
}

void ChatParticipantList::operator =(const QList<ChatParticipant> &another)
{
    foreach( ChatParticipantObject *obj, p->list )
        obj->deleteLater();

    p->list.clear();

    foreach( const ChatParticipant & size, another )
    {
        ChatParticipantObject *obj = new ChatParticipantObject(size, this);
        p->list << obj;
    }

    emit firstChanged();
    emit lastChanged();
    emit countChanged();
}

QList<qint64> ChatParticipantList::userIds() const
{
    QList<qint64> results;
    foreach( ChatParticipantObject *obj, p->list )
        results << obj->userId();

    return results;
}

ChatParticipantObject *ChatParticipantList::first() const
{
    if( p->list.isEmpty() )
        return 0;

    return p->list.first();
}

ChatParticipantObject *ChatParticipantList::last() const
{
    if( p->list.isEmpty() )
        return 0;

    return p->list.last();
}

int ChatParticipantList::count() const
{
    return p->list.count();
}

ChatParticipantObject *ChatParticipantList::at(int idx)
{
    return p->list.at(idx);
}

ChatParticipantList::~ChatParticipantList()
{
    delete p;
}
