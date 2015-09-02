#include "contributorsmodel.h"

#include <QFile>
#include <QStringList>
#include <QDebug>

class ContributorsModelItem
{
public:
    QString nick;
    QString name;
    QString role;
    QString link;
    QString type;

    bool operator ==(const ContributorsModelItem &b) {
        return nick == b.nick &&
               name == b.name &&
               role == b.role &&
               link == b.link &&
               type == b.type;
    }
};

class ContributorsModelPrivate
{
public:
    QList<ContributorsModelItem> items;
    QList<QUrl> files;
};

ContributorsModel::ContributorsModel(QObject *parent) :
    AsemanAbstractListModel(parent)
{
    p = new ContributorsModelPrivate;
}

void ContributorsModel::setFiles(const QList<QUrl> &urls)
{
    if(p->files == urls)
        return;

    p->files = urls;
    emit filesChanged();

    refresh();
}

QList<QUrl> ContributorsModel::files() const
{
    return p->files;
}

int ContributorsModel::id(const QModelIndex &index) const
{
    return index.row();
}

int ContributorsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return count();
}

QVariant ContributorsModel::data(const QModelIndex &index, int role) const
{
    const int id = ContributorsModel::id(index);
    const ContributorsModelItem &item = p->items.at(id);
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

QHash<qint32, QByteArray> ContributorsModel::roleNames() const
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

int ContributorsModel::count() const
{
    return p->items.count();
}

void ContributorsModel::refresh()
{
    const QList<ContributorsModelItem> &items = readData();

    for( int i=0 ; i<p->items.count() ; i++ )
    {
        const ContributorsModelItem & dId = p->items.at(i);
        if( items.contains(dId) )
            continue;

        beginRemoveRows(QModelIndex(), i, i);
        p->items.removeAt(i);
        i--;
        endRemoveRows();
    }

    QList<ContributorsModelItem> temp_msgs = items;
    for( int i=0 ; i<temp_msgs.count() ; i++ )
    {
        const ContributorsModelItem & dId = temp_msgs.at(i);
        if( p->items.contains(dId) )
            continue;

        temp_msgs.removeAt(i);
        i--;
    }
    while( p->items != temp_msgs )
        for( int i=0 ; i<p->items.count() ; i++ )
        {
            const ContributorsModelItem & dId = p->items.at(i);
            int nw = temp_msgs.indexOf(dId);
            if( i == nw )
                continue;

            beginMoveRows( QModelIndex(), i, i, QModelIndex(), nw>i?nw+1:nw );
            p->items.move( i, nw );
            endMoveRows();
        }


    for( int i=0 ; i<items.count() ; i++ )
    {
        const ContributorsModelItem & dId = items.at(i);
        if( p->items.contains(dId) )
            continue;

        beginInsertRows(QModelIndex(), i, i );
        p->items.insert( i, dId );
        endInsertRows();
    }

    emit countChanged();
}

QList<ContributorsModelItem> ContributorsModel::readData() const
{
    QList<ContributorsModelItem> result;

    foreach(const QUrl &url, p->files)
    {
        const QString &f = url.toString();

        QFile file(f.left(5)=="qrc:/"?f.mid(3):f);
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
        foreach(const QString &l, lines)
        {
            QStringList columns = l.split(",");
            if(columns.length() < 3)
                continue;

            ContributorsModelItem item;
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

ContributorsModel::~ContributorsModel()
{
    delete p;
}

