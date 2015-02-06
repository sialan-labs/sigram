#include "dialogfilesmodel.h"
#include "telegramqml.h"
#include "objects/types.h"

class DialogFilesModelPrivate
{
public:
    QStringList list;
    TelegramQml *telegram;
    DialogObject *dialog;
};

DialogFilesModel::DialogFilesModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new DialogFilesModelPrivate;
    p->telegram = 0;
    p->dialog = 0;
}

TelegramQml *DialogFilesModel::telegram() const
{
    return p->telegram;
}

void DialogFilesModel::setTelegram(TelegramQml *tg)
{
    if(p->telegram == tg)
        return;

    p->telegram = tg;
    emit telegramChanged();

    refresh();
}

DialogObject *DialogFilesModel::dialog() const
{
    return p->dialog;
}

void DialogFilesModel::setDialog(DialogObject *dlg)
{
    if(p->dialog == dlg)
        return;

    p->dialog = dlg;
    emit dialogChanged();

    refresh();
}

QString DialogFilesModel::id(const QModelIndex &index) const
{
    return p->list.at(index.row());
}

int DialogFilesModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return p->list.count();
}

QVariant DialogFilesModel::data(const QModelIndex &index, int role) const
{
    const QString &fileName = id(index);
    QVariant res;
    if(!p->telegram || !p->dialog)
        return res;

    switch(role)
    {
    case Qt::DisplayRole:
    case NameRole:
        res = fileName;
        break;

    case PathRole:
    case ThumbnailRole:
        res = dirPath() + "/" + fileName;
        break;

    case SuffixRole:
        res = "";
        break;
    }

    return res;
}

QHash<qint32, QByteArray> DialogFilesModel::roleNames() const
{
    QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( NameRole, "name");
    res->insert( PathRole, "path");
    res->insert( ThumbnailRole, "thumbnail");
    res->insert( SuffixRole, "suffix");
    return *res;
}

int DialogFilesModel::count() const
{
    return p->list.count();
}

void DialogFilesModel::refresh()
{
    QStringList list;
    if(p->dialog && p->telegram)
        list = QDir(dirPath()).entryList(QDir::Files, QDir::Time|QDir::Reversed);

    for( int i=0 ; i<p->list.count() ; i++ )
    {
        const QString & dId = p->list.at(i);
        if( list.contains(dId) )
            continue;

        beginRemoveRows(QModelIndex(), i, i);
        p->list.removeAt(i);
        i--;
        endRemoveRows();
    }


    QList<QString> temp_msgs = list;
    for( int i=0 ; i<temp_msgs.count() ; i++ )
    {
        const QString & dId = temp_msgs.at(i);
        if( p->list.contains(dId) )
            continue;

        temp_msgs.removeAt(i);
        i--;
    }
    while( p->list != temp_msgs )
        for( int i=0 ; i<p->list.count() ; i++ )
        {
            const QString & dId = p->list.at(i);
            int nw = temp_msgs.indexOf(dId);
            if( i == nw )
                continue;

            beginMoveRows( QModelIndex(), i, i, QModelIndex(), nw>i?nw+1:nw );
            p->list.move( i, nw );
            endMoveRows();
        }


    for( int i=0 ; i<list.count() ; i++ )
    {
        const QString & dId = list.at(i);
        if( p->list.contains(dId) )
            continue;

        beginInsertRows(QModelIndex(), i, i );
        p->list.insert( i, dId );
        endInsertRows();
    }

    emit countChanged();
}

QString DialogFilesModel::dirPath() const
{
    if(!p->telegram || !p->dialog)
        return QString();

    qint64 dId = p->dialog->peer()->chatId();
    if(!dId)
        dId = p->dialog->peer()->userId();

    return p->telegram->downloadPath() + "/" + QString::number(dId);
}

DialogFilesModel::~DialogFilesModel()
{
    delete p;
}

