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

#include "asemancontributorsmodel.h"
#include "asemandevices.h"

#include <QFile>
#include <QStringList>
#include <QDebug>

class AsemanContributorsModelItem
{
public:
    QString nick;
    QString name;
    QString role;
    QString link;
    QString type;

    bool operator ==(const AsemanContributorsModelItem &b) {
        return nick == b.nick &&
               name == b.name &&
               role == b.role &&
               link == b.link &&
               type == b.type;
    }
};

class AsemanContributorsModelPrivate
{
public:
    QList<AsemanContributorsModelItem> items;
    QList<QUrl> files;
};

AsemanContributorsModel::AsemanContributorsModel(QObject *parent) :
    AsemanAbstractListModel(parent)
{
    p = new AsemanContributorsModelPrivate;
}

void AsemanContributorsModel::setFiles(const QList<QUrl> &urls)
{
    if(p->files == urls)
        return;

    p->files = urls;
    Q_EMIT filesChanged();

    refresh();
}

QList<QUrl> AsemanContributorsModel::files() const
{
    return p->files;
}

int AsemanContributorsModel::id(const QModelIndex &index) const
{
    return index.row();
}

int AsemanContributorsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return count();
}

QVariant AsemanContributorsModel::data(const QModelIndex &index, int role) const
{
    const int id = AsemanContributorsModel::id(index);
    const AsemanContributorsModelItem &item = p->items.at(id);
    QVariant result;

    switch(role)
    {
    case TextRole:
        if(item.nick.isEmpty())
            result = item.role.isEmpty()? item.name : tr("%1 - %2").arg(item.name, item.role);
        if(item.name.isEmpty())
            result = item.role.isEmpty()? item.nick : tr("%1 - %2").arg(item.nick, item.role);
        else
            result = item.role.isEmpty()? tr("%1 (%2)").arg(item.nick, item.name) : tr("%1 (%2) - %3").arg(item.nick, item.name, item.role);
        break;

    case LinkRole:
        result = item.link;
        break;

    case TypeRole:
        result = item.type;
        break;
    }

    return result;
}

QHash<qint32, QByteArray> AsemanContributorsModel::roleNames() const
{
    static QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( TextRole, "text");
    res->insert( LinkRole, "link");
    res->insert( TypeRole, "type");
    return *res;
}

int AsemanContributorsModel::count() const
{
    return p->items.count();
}

void AsemanContributorsModel::refresh()
{
    const QList<AsemanContributorsModelItem> &items = readData();

    for( int i=0 ; i<p->items.count() ; i++ )
    {
        const AsemanContributorsModelItem & dId = p->items.at(i);
        if( items.contains(dId) )
            continue;

        beginRemoveRows(QModelIndex(), i, i);
        p->items.removeAt(i);
        i--;
        endRemoveRows();
    }

    QList<AsemanContributorsModelItem> temp_msgs = items;
    for( int i=0 ; i<temp_msgs.count() ; i++ )
    {
        const AsemanContributorsModelItem & dId = temp_msgs.at(i);
        if( p->items.contains(dId) )
            continue;

        temp_msgs.removeAt(i);
        i--;
    }
    while( p->items != temp_msgs )
        for( int i=0 ; i<p->items.count() ; i++ )
        {
            const AsemanContributorsModelItem & dId = p->items.at(i);
            int nw = temp_msgs.indexOf(dId);
            if( i == nw )
                continue;

            beginMoveRows( QModelIndex(), i, i, QModelIndex(), nw>i?nw+1:nw );
            p->items.move( i, nw );
            endMoveRows();
        }


    for( int i=0 ; i<items.count() ; i++ )
    {
        const AsemanContributorsModelItem & dId = items.at(i);
        if( p->items.contains(dId) )
            continue;

        beginInsertRows(QModelIndex(), i, i );
        p->items.insert( i, dId );
        endInsertRows();
    }

    Q_EMIT countChanged();
}

QList<AsemanContributorsModelItem> AsemanContributorsModel::readData() const
{
    QList<AsemanContributorsModelItem> result;

    for(const QUrl &url: p->files)
    {
        QString f = url.toString();
        if(f.left(5)=="qrc:/")
            f = f.mid(3);
        if(f.left(AsemanDevices::localFilesPrePath().length()) == AsemanDevices::localFilesPrePath())
            f = f.mid(AsemanDevices::localFilesPrePath().length());

        QFile file(f);
        if(!file.open(QFile::ReadOnly))
            continue;

        QString type = f.mid(f.lastIndexOf("/")+1);
        QStringList typeParts = type.split("-",QString::SkipEmptyParts);
        for(int i=0; i<typeParts.count(); i++)
        {
            QString &t = typeParts[i];
            if(!t.isEmpty())
                t = t[0].toUpper() + t.mid(1);
        }
        type = typeParts.join(" ");

        const QString &data = file.readAll();
        file.close();

        const QStringList &lines = data.split("\n", QString::SkipEmptyParts);
        for(const QString &l: lines)
        {
            QStringList columns = l.split(",");
            if(columns.length() < 3)
                continue;

            AsemanContributorsModelItem item;
            item.nick = columns.at(0);
            item.name = columns.at(1);
            item.role = columns.length()==3? QString() : columns.at(2);
            item.link = columns.last();
            item.type = type;

            result << item;
        }
    }

    return result;
}

AsemanContributorsModel::~AsemanContributorsModel()
{
    delete p;
}
