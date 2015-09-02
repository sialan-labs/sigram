#define MAX_RECENT 30

#include "emoticonsmodel.h"
#include "asemantools/asemanapplication.h"

#include <QList>
#include <QHash>
#include <QPointer>
#include <QDir>
#include <QSettings>
#include <QDebug>

class EmoticonsModelPrivate
{
public:
    QStringList list;
    QStringList keys;
    QList<QUrl> keysIcons;
    QHash<QString,QString> keysPath;

    QString currentKey;

    QPointer<Emojis> emojis;
    QList<QUrl> stickerSubPaths;
    int type;
    QUrl icon;
};

EmoticonsModel::EmoticonsModel(QObject *parent) :
    AsemanAbstractListModel(parent)
{
    p = new EmoticonsModelPrivate;
    p->type = EmoticonEmoji;

    refreshKeys();
}

void EmoticonsModel::setEmojis(Emojis *emojis)
{
    if(p->emojis == emojis)
        return;

    p->emojis = emojis;
    emit emojisChanged();

    refresh();
}

Emojis *EmoticonsModel::emojis() const
{
    return p->emojis;
}

void EmoticonsModel::setStickerSubPaths(const QList<QUrl> &subpaths)
{
    if(p->stickerSubPaths == subpaths)
        return;

    p->stickerSubPaths = subpaths;
    emit stickerSubPathsChanged();

    refreshKeys();
}

QList<QUrl> EmoticonsModel::stickerSubPaths() const
{
    return p->stickerSubPaths;
}

QStringList EmoticonsModel::keys() const
{
    return p->keys;
}

QStringList EmoticonsModel::recentKeys() const
{
    return AsemanApplication::settings()->value("General/recentEmojis", QVariant::fromValue<QStringList>(p->emojis->keys().mid(0,20))).toStringList();
}

QList<QUrl> EmoticonsModel::keysIcons() const
{
    return p->keysIcons;
}

void EmoticonsModel::setCurrentKey(const QString &key)
{
    if(p->currentKey == key)
        return;

    p->currentKey = key;
    emit currentKeyChanged();
    emit currentKeyIndexChanged();

    refresh();
}

QString EmoticonsModel::currentKey() const
{
    return p->currentKey;
}

int EmoticonsModel::currentKeyIndex() const
{
    int currentKeyIndex = p->keys.indexOf(p->currentKey);
    if(currentKeyIndex == -1)
        return 0;

    return currentKeyIndex;
}

QString EmoticonsModel::id(const QModelIndex &index) const
{
    const int row = index.row();
    return p->list.at(row);
}

int EmoticonsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return count();
}

QVariant EmoticonsModel::data(const QModelIndex &index, int role) const
{
    const QString &id = EmoticonsModel::id(index);
    QVariant result;

    switch(role)
    {
    case KeyRole:
        result = id;
        break;

    case TypeRole:
        result = p->type;
        break;

    case PathRole:
        if(p->type == EmoticonSticker)
        {
            const QString key = currentKey();
            const QString &path = p->keysPath.value(key);
            result = QUrl::fromLocalFile(path + "/" + id);
        }
        else
        if(p->emojis)
            result = QUrl::fromLocalFile(p->emojis->pathOf(id));
        break;

    case IconRole:
        result = p->icon;
        break;
    }

    return result;
}

QHash<qint32, QByteArray> EmoticonsModel::roleNames() const
{
    static QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( KeyRole, "key");
    res->insert( TypeRole, "type");
    res->insert( PathRole, "path");
    res->insert( IconRole, "icon");
    return *res;
}

int EmoticonsModel::count() const
{
    return p->list.count();
}

void EmoticonsModel::refresh()
{
    QStringList newList;
    const int index = currentKeyIndex();
    if(index == 0) // is recent
    {
        if(p->emojis)
            newList = AsemanApplication::settings()->value("General/recentEmojis",
                                QVariant::fromValue<QStringList>(p->emojis->keys().mid(0,MAX_RECENT))).toStringList();

        p->type = EmoticonEmoji;
    }
    else
    if(index == 1) // is emojis
    {
        if(p->emojis)
            newList = p->emojis->keys();

        p->type = EmoticonEmoji;
    }
    else // is sticker
    {
        const QString key = currentKey();
        const QString &path = p->keysPath.value(key);
        newList = QDir(path).entryList(QStringList()<<"*.webp",QDir::Files);

        p->type = EmoticonSticker;
    }

    changed(newList);
}

void EmoticonsModel::pushToRecent(const QString &key)
{
    QStringList recent = recentKeys();
    recent.removeAll(key);
    recent.prepend(key);
    recent = recent.mid(0, MAX_RECENT);

    AsemanApplication::settings()->setValue("General/recentEmojis", QVariant::fromValue<QStringList>(recent));
    emit recentKeysChanged();
}

void EmoticonsModel::refreshKeys()
{
    p->keys.clear();
    p->keysPath.clear();
    p->keysIcons.clear();

    p->keys.append(tr("Recent"));
    p->keys.append(tr("Emojis"));

    p->keysIcons << QUrl("qrc:/qml/Cutegram/files/emoticons-recent.png");
    p->keysIcons << QUrl("qrc:/qml/Cutegram/files/emoticons-emoji.png");

    foreach(const QUrl &subPathUrl, p->stickerSubPaths)
    {
        const QString &subPath = subPathUrl.toLocalFile();
        QStringList stickers = QDir(subPath).entryList(QDir::Dirs|QDir::NoDotAndDotDot);
        foreach(const QString &sticker, stickers)
        {
            if(p->keys.contains(sticker))
                continue;

            const QString stickerPath = subPath + "/" + sticker;
            p->keys << sticker;
            p->keysPath[sticker] = stickerPath;
            if(sticker.toLower() == "personal")
                p->keysIcons << QUrl("qrc:/qml/Cutegram/files/emoticons-personal.png");
            else
                p->keysIcons << QUrl("qrc:/qml/Cutegram/files/emoticons-telegram.png");
        }
    }

    emit keysChanged();
    emit keysIconsChanged();
}

void EmoticonsModel::changed(const QStringList &list)
{
    for( int i=0 ; i<p->list.count() ; i++ )
    {
        const QString &key = p->list.at(i);
        if( list.contains(key) )
            continue;

        beginRemoveRows(QModelIndex(), i, i);
        p->list.removeAt(i);
        i--;
        endRemoveRows();
    }


    QStringList temp_list = list;
    for( int i=0 ; i<temp_list.count() ; i++ )
    {
        const QString &key = temp_list.at(i);
        if( p->list.contains(key) )
            continue;

        temp_list.removeAt(i);
        i--;
    }
    while( p->list != temp_list )
        for( int i=0 ; i<p->list.count() ; i++ )
        {
            const QString &key = p->list.at(i);
            int nw = temp_list.indexOf(key);
            if( i == nw )
                continue;

            beginMoveRows( QModelIndex(), i, i, QModelIndex(), nw>i?nw+1:nw );
            p->list.move( i, nw );
            endMoveRows();
        }


    for( int i=0 ; i<list.count() ; i++ )
    {
        const QString &key = list.at(i);
        if( p->list.contains(key) )
            continue;

        beginInsertRows(QModelIndex(), i, i );
        p->list.insert( i, key );
        endInsertRows();
    }

    emit countChanged();
}

EmoticonsModel::~EmoticonsModel()
{
    delete p;
}

