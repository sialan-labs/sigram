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

#ifndef CHATPARTICIPANTLIST_H
#define CHATPARTICIPANTLIST_H

#include <QObject>

class ChatParticipant;
class ChatParticipantObject;
class ChatParticipantListPrivate;
class ChatParticipantList : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    ChatParticipantList(QObject *parent = 0);
    ChatParticipantList(const QList<ChatParticipant> & another, QObject *parent = 0);
    ~ChatParticipantList();

    void operator =( const QList<ChatParticipant> & another );
    QList<qint64> userIds() const;

    ChatParticipantObject *first() const;
    ChatParticipantObject *last() const;

    int count() const;

public slots:
    ChatParticipantObject *at( int idx );

signals:
    void firstChanged();
    void lastChanged();
    void countChanged();

private:
    ChatParticipantListPrivate *p;
};

Q_DECLARE_METATYPE(ChatParticipantList*)

#endif // CHATPARTICIPANTLIST_H
