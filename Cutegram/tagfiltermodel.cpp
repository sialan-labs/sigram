#include "tagfiltermodel.h"
#include "userdata.h"

#include <QPointer>
#include <QStringList>

class TagFilterModelPrivate
{
public:
    QPointer<UserData> userData;
    QStringList tags;
    QString keyword;
};

TagFilterModel::TagFilterModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new TagFilterModelPrivate;
}

void TagFilterModel::setUserData(UserData *userData)
{
    if(p->userData == userData)
        return;

    if(p->userData)
        disconnect(p->userData, SIGNAL(tagsChanged(QString)), this, SLOT(refresh()));

    p->userData = userData;
    if(p->userData)
        connect(p->userData, SIGNAL(tagsChanged(QString)), this, SLOT(refresh()));

    emit userDataChanged();

    refresh();
}

UserData *TagFilterModel::userData() const
{
    return p->userData;
}

QString TagFilterModel::id(const QModelIndex &index) const
{
    const int row = index.row();
    return p->tags.at(row);
}

int TagFilterModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return count();
}

QVariant TagFilterModel::data(const QModelIndex &index, int role) const
{
    QVariant result;
    const QString &tag = id(index);
    switch(role)
    {
    case TagRole:
        result = tag;
        break;
    }

    return result;
}

QHash<qint32, QByteArray> TagFilterModel::roleNames() const
{
    static QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( TagRole, "tag");
    return *res;
}

int TagFilterModel::count() const
{
    return p->tags.count();
}

void TagFilterModel::setKeyword(const QString &keyword)
{
    if(p->keyword == keyword)
        return;

    p->keyword = keyword;
    emit keywordChanged();

    refresh();
}

QString TagFilterModel::keyword() const
{
    return p->keyword;
}

void TagFilterModel::refresh()
{
    listChanged();
}

QString TagFilterModel::get(int idx)
{
    if(idx < 0 || idx >= p->tags.count())
        return 0;

    return p->tags.at(idx);
}

void TagFilterModel::listChanged()
{
    QStringList tags;
    if(p->userData)
        tags = p->userData->tags();

    const QString &keywod = p->keyword.toLower();
    for(int i=0; i<tags.count(); i++)
    {
        if(tags.at(i).contains(keywod))
            continue;

        tags.removeAt(i);
        i--;
    }

    for( int i=0 ; i<p->tags.count() ; i++ )
    {
        const QString &tag = p->tags.at(i);
        if( tags.contains(tag) )
            continue;

        beginRemoveRows(QModelIndex(), i, i);
        p->tags.removeAt(i);
        i--;
        endRemoveRows();
    }


    QStringList temp_tags = tags;
    for( int i=0 ; i<temp_tags.count() ; i++ )
    {
        const QString &tag = temp_tags.at(i);
        if( p->tags.contains(tag) )
            continue;

        temp_tags.removeAt(i);
        i--;
    }
    while( p->tags != temp_tags )
        for( int i=0 ; i<p->tags.count() ; i++ )
        {
            const QString &tag = p->tags.at(i);
            int nw = temp_tags.indexOf(tag);
            if( i == nw )
                continue;

            beginMoveRows( QModelIndex(), i, i, QModelIndex(), nw>i?nw+1:nw );
            p->tags.move( i, nw );
            endMoveRows();
        }


    for( int i=0 ; i<tags.count() ; i++ )
    {
        const QString &tag = tags.at(i);
        if( p->tags.contains(tag) )
            continue;

        beginInsertRows(QModelIndex(), i, i );
        p->tags.insert( i, tag );
        endInsertRows();
    }

    emit countChanged();
}

TagFilterModel::~TagFilterModel()
{
    delete p;
}

