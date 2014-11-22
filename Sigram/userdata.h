/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef USERDATA_H
#define USERDATA_H

#include <QObject>

class UserDataPrivate;
class UserData : public QObject
{
    Q_OBJECT
public:
    UserData(const QString &phoneNumber, QObject *parent = 0);
    ~UserData();

public slots:
    void addMute( int id );
    void removeMute( int id );
    QList<int> mutes() const;
    bool isMuted(int id);

    void addFavorite( int id );
    void removeFavorite( int id );
    QList<int> favorites() const;
    bool isFavorited(int id);

    void setValue( const QString & key, const QString & value );
    QString value( const QString & key );

    void reconnect();
    void disconnect();

signals:
    void muteChanged(int id);
    void favoriteChanged(int id);
    void valueChanged( const QString & key );

private:
    void init_buffer();
    void update_db();

private:
    UserDataPrivate *p;
};

Q_DECLARE_METATYPE(UserData*)

#endif // USERDATA_H
