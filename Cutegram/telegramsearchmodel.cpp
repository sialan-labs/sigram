#include "telegramsearchmodel.h"
#include "telegramqml.h"
#include "objects/types.h"

#include <QTimerEvent>

class TelegramSearchModelPrivate
{
public:
    TelegramQml *telegram;
    QString keyword;

    bool initializing;
    int refresh_timer;

    QList<qint64> messages;
};

TelegramSearchModel::TelegramSearchModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new TelegramSearchModelPrivate;
    p->refresh_timer = 0;
    p->telegram = 0;
    p->initializing = false;
}

TelegramQml *TelegramSearchModel::telegram() const
{
    return p->telegram;
}

void TelegramSearchModel::setTelegram(TelegramQml *tgo)
{
    TelegramQml *tg = static_cast<TelegramQml*>(tgo);
    if( p->telegram == tg )
        return;

    if( !tg && p->telegram )
    {
        disconnect( p->telegram, SIGNAL(searchDone(QList<qint64>)) , this, SLOT(searchDone(QList<qint64>)) );
    }

    p->telegram = tg;
    emit telegramChanged();

    p->initializing = false;
    emit initializingChanged();
    if( !p->telegram )
        return;

    connect( p->telegram, SIGNAL(searchDone(QList<qint64>)) , this, SLOT(searchDone(QList<qint64>)) );
    refresh();
}

void TelegramSearchModel::setKeyword(const QString &kw)
{
    if(p->keyword == kw)
        return;

    p->keyword = kw;
    emit keywordChanged();
    refresh();
}

QString TelegramSearchModel::keyword() const
{
    return p->keyword;
}

qint64 TelegramSearchModel::id(const QModelIndex &index) const
{
    int row = index.row();
    return p->messages.at(row);
}

int TelegramSearchModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return p->messages.count();
}

QVariant TelegramSearchModel::data(const QModelIndex &index, int role) const
{
    QVariant res;
    const qint64 key = id(index);
    switch( role )
    {
    case ItemRole:
        res = QVariant::fromValue<MessageObject*>(p->telegram->message(key));
        break;
    }

    return res;
}

QHash<qint32, QByteArray> TelegramSearchModel::roleNames() const
{
    QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( ItemRole, "item");
    return *res;
}

int TelegramSearchModel::count() const
{
    return p->messages.count();
}

bool TelegramSearchModel::initializing() const
{
    return p->initializing;
}

void TelegramSearchModel::refresh()
{
    searchDone(QList<qint64>());

    if(p->refresh_timer)
        killTimer(p->refresh_timer);

    p->refresh_timer = 0;
    if(!p->telegram)
        return;

    p->refresh_timer = startTimer(1000);
}

void TelegramSearchModel::searchDone(const QList<qint64> &messages)
{
    p->initializing = false;
    emit initializingChanged();

    for( int i=0 ; i<p->messages.count() ; i++ )
    {
        const qint64 dId = p->messages.at(i);
        if( messages.contains(dId) )
            continue;

        beginRemoveRows(QModelIndex(), i, i);
        p->messages.removeAt(i);
        i--;
        endRemoveRows();
    }


    QList<qint64> temp_msgs = messages;
    for( int i=0 ; i<temp_msgs.count() ; i++ )
    {
        const qint64 dId = temp_msgs.at(i);
        if( p->messages.contains(dId) )
            continue;

        temp_msgs.removeAt(i);
        i--;
    }
    while( p->messages != temp_msgs )
        for( int i=0 ; i<p->messages.count() ; i++ )
        {
            const qint64 dId = p->messages.at(i);
            int nw = temp_msgs.indexOf(dId);
            if( i == nw )
                continue;

            beginMoveRows( QModelIndex(), i, i, QModelIndex(), nw>i?nw+1:nw );
            p->messages.move( i, nw );
            endMoveRows();
        }


    for( int i=0 ; i<messages.count() ; i++ )
    {
        const qint64 dId = messages.at(i);
        if( p->messages.contains(dId) )
            continue;

        beginInsertRows(QModelIndex(), i, i );
        p->messages.insert( i, dId );
        endInsertRows();
    }

    emit countChanged();
}

void TelegramSearchModel::timerEvent(QTimerEvent *e)
{
    if(e->timerId() == p->refresh_timer)
    {
        killTimer(p->refresh_timer);
        p->refresh_timer = 0;

        if(!p->keyword.isEmpty())
        {
            p->initializing = true;
            emit initializingChanged();
            p->telegram->search(p->keyword);
        }
        else
        {
            p->initializing = false;
            emit initializingChanged();
        }
    }
}

TelegramSearchModel::~TelegramSearchModel()
{
    delete p;
}

