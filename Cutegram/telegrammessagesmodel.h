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

#ifndef TELEGRAMMESSAGESMODEL_H
#define TELEGRAMMESSAGESMODEL_H

#include <QAbstractListModel>

class Peer;
class InputPeer;
class DialogObject;
class TelegramMessagesModelPrivate;
class TelegramMessagesModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QObject* telegram READ telegram WRITE setTelegram NOTIFY telegramChanged)
    Q_PROPERTY(DialogObject* dialog READ dialog WRITE setDialog NOTIFY dialogChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool initializing READ initializing NOTIFY initializingChanged)
    Q_PROPERTY(bool refreshing  READ refreshing  NOTIFY refreshingChanged)
    Q_PROPERTY(int maxId READ maxId WRITE setMaxId NOTIFY maxIdChanged)

public:
    enum MessagesRoles {
        ItemRole = Qt::UserRole
    };

    TelegramMessagesModel(QObject *parent = 0);
    ~TelegramMessagesModel();

    QObject *telegram() const;
    void setTelegram( QObject *tg );

    DialogObject *dialog() const;
    void setDialog( DialogObject *dlg );

    void setMaxId(int id);
    int maxId() const;

    Q_INVOKABLE int indexOf(qint64 msgId) const;

    qint64 id( const QModelIndex &index ) const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;

    int count() const;
    bool initializing() const;
    bool refreshing() const;

    InputPeer inputPeer() const;
    Peer peer() const;

public slots:
    void refresh();
    void loadMore(bool force = false);
    void sendMessage( const QString & msg );
    void setReaded();

signals:
    void telegramChanged();
    void dialogChanged();
    void countChanged();
    void initializingChanged();
    void refreshingChanged();
    void maxIdChanged();
    void messageAdded(qint64 msgId);

private slots:
    void messagesChanged(bool cachedData);
    void init();

private:
    TelegramMessagesModelPrivate *p;
};

#endif // TELEGRAMMESSAGESMODEL_H
