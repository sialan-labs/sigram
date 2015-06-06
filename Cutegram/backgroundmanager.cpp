#include "backgroundmanager.h"
#include "objects/types.h"

#include <QPointer>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QStringList>

class BackgroundManagerPrivate
{
public:
    QUrl directory;
    QPointer<DialogObject> dialog;
    QUrl background;
};

BackgroundManager::BackgroundManager(QObject *parent) :
    QObject(parent)
{
    p = new BackgroundManagerPrivate;
}

void BackgroundManager::setDirectory(const QUrl &path)
{
    if(p->directory == path)
        return;

    p->directory = path;

    QDir().mkpath(p->directory.toLocalFile());
    emit directoryChanged();

    refresh();
}

QUrl BackgroundManager::directory() const
{
    return p->directory;
}

void BackgroundManager::setDialog(DialogObject *dialog)
{
    if(p->dialog == dialog)
        return;

    p->dialog = dialog;
    emit dialogChanged();

    refresh();
}

DialogObject *BackgroundManager::dialog() const
{
    return p->dialog;
}

QUrl BackgroundManager::background() const
{
    return p->background;
}

qint64 BackgroundManager::dialogId()
{
    if(!p->dialog || p->directory.isEmpty())
        return 0;

    qint64 dId = p->dialog->peer()->chatId()? p->dialog->peer()->chatId() :
                                              p->dialog->peer()->userId();
    if(!dId)
        return 0;

    return dId;
}

void BackgroundManager::setBackground(const QString &filePath)
{
    const qint64 dId = dialogId();
    if(!dId)
    {
        p->background = QUrl();
        emit backgroundChanged();
        return;
    }

    const QString dIdStr = QString::number(dId);
    const QStringList &files = QDir(p->directory.toLocalFile()).entryList(QDir::Files);
    foreach(const QString &f, files)
    {
        const QString path = p->directory.toLocalFile() + "/" + f;
        QFileInfo info(path);
        if(info.baseName() != dIdStr)
            continue;

        QFile::remove(path);
    }

    if(!filePath.isEmpty())
    {
        QFileInfo inf(filePath);
        QFile::copy(filePath, p->directory.toLocalFile() + "/" + dIdStr + "." + inf.suffix());
    }

    refresh();
}

void BackgroundManager::refresh()
{
    const qint64 dId = dialogId();
    if(!dId)
    {
        p->background = QUrl();
        emit backgroundChanged();
        return;
    }

    QString filePath;
    const QString dIdStr = QString::number(dId);
    const QStringList &files = QDir(p->directory.toLocalFile()).entryList(QDir::Files);
    foreach(const QString &f, files)
    {
        const QString path = p->directory.toLocalFile() + "/" + f;
        QFileInfo info(path);
        if(info.baseName() != dIdStr)
            continue;

        filePath = path;
        break;
    }

    p->background = filePath.isEmpty()? QUrl() : QUrl::fromLocalFile(filePath);
    emit backgroundChanged();
}

BackgroundManager::~BackgroundManager()
{
    delete p;
}

