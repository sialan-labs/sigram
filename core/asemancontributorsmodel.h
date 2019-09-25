/*
    Copyright (C) 2017 Aseman Team
    http://aseman.co

    AsemanQtTools is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    AsemanQtTools is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef ASEMANCONTRIBUTORSMODEL_H
#define ASEMANCONTRIBUTORSMODEL_H

#include "asemanabstractlistmodel.h"
#include <QList>
#include <QUrl>

class AsemanContributorsModelItem;
class AsemanContributorsModelPrivate;
class AsemanContributorsModel : public AsemanAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(ItemRoles)

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QList<QUrl> files READ files WRITE setFiles NOTIFY filesChanged)

public:
    enum ItemRoles {
        TextRole = Qt::UserRole,
        LinkRole,
        TypeRole
    };

    AsemanContributorsModel(QObject *parent = 0);
    virtual ~AsemanContributorsModel();

    void setFiles(const QList<QUrl> & urls);
    QList<QUrl> files() const;

    int id( const QModelIndex &index ) const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;

    int count() const;

public Q_SLOTS:
    void refresh();

Q_SIGNALS:
    void countChanged();
    void filesChanged();

private:
    QList<AsemanContributorsModelItem> readData() const;

private:
    AsemanContributorsModelPrivate *p;
};

#endif // ASEMANCONTRIBUTORSMODEL_H
