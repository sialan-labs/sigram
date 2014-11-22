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

#ifndef TELEGRAMCONTACTSMODEL_H
#define TELEGRAMCONTACTSMODEL_H

#include <QAbstractListModel>

class TelegramQml;
class TelegramContactsModelPrivate;
class TelegramContactsModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(TelegramQml* telegram READ telegram WRITE setTelegram NOTIFY telegramChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool initializing READ initializing NOTIFY initializingChanged)

public:
    enum DialogsRoles {
        ItemRole = Qt::UserRole
    };

    TelegramContactsModel(QObject *parent = 0);
    ~TelegramContactsModel();

    TelegramQml *telegram() const;
    void setTelegram(TelegramQml *tg );

    qint64 id( const QModelIndex &index ) const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;

    int count() const;
    bool initializing() const;

public slots:
    void refresh();

signals:
    void telegramChanged();
    void countChanged();
    void initializingChanged();

private slots:
    void contactsChanged();

private:
    TelegramContactsModelPrivate *p;
};

#endif // TELEGRAMCONTACTSMODEL_H
