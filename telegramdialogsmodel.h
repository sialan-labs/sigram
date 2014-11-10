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

#ifndef TELEGRAMDIALOGSMODEL_H
#define TELEGRAMDIALOGSMODEL_H

#include <QAbstractListModel>

class Message;
class User;
class Chat;
class Dialog;
class Telegram;
class TelegramDialogsModelPrivate;
class TelegramDialogsModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(Telegram* telegram READ telegram WRITE setTelegram NOTIFY telegramChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool intializing READ intializing NOTIFY intializingChanged)

public:
    TelegramDialogsModel(QObject *parent = 0);
    ~TelegramDialogsModel();

    Telegram *telegram() const;
    void setTelegram( Telegram *tg );

    QString id( const QModelIndex &index ) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    bool setData(const QModelIndex & index, const QVariant & value, int role = Qt::EditRole);

    QHash<qint32,QByteArray> roleNames() const;
    Qt::ItemFlags flags(const QModelIndex &index) const;

    int count() const;
    bool intializing() const;

signals:
    void telegramChanged();
    void countChanged();
    void intializingChanged();

private slots:
    void messagesGetDialogsAnswer(qint64 id, qint32 sliceCount, const QList<Dialog> & dialogs, const QList<Message> & messages, const QList<Chat> & chats, const QList<User> & users);

private:
    TelegramDialogsModelPrivate *p;
};

#endif // TELEGRAMDIALOGSMODEL_H
