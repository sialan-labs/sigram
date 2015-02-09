#include "asemanautostartmanager.h"

#include <QFile>
#include <QDir>

class AsemanAutoStartManagerPrivate
{
public:
    QString type;
    bool active;
    QString name;
    QString command;
    QString comment;

    QString source;
};

AsemanAutoStartManager::AsemanAutoStartManager(QObject *parent) :
    QObject(parent)
{
    p = new AsemanAutoStartManagerPrivate;
    p->type = "Application";
    p->active = true;
}

void AsemanAutoStartManager::setCommand(const QString &cmd)
{
    if(p->command == cmd)
        return;

    p->command = cmd;
    emit commandChanged();

    save();
}

QString AsemanAutoStartManager::command() const
{
    return p->command;
}

void AsemanAutoStartManager::setSource(const QString &fileName)
{
    if(p->source == fileName)
        return;

    p->source = fileName;
    emit sourceChanged();

    refresh();
}

QString AsemanAutoStartManager::source() const
{
    return p->source;
}

void AsemanAutoStartManager::setComment(const QString &txt)
{
    if(p->comment == txt)
        return;

    p->comment = txt;
    emit commentChanged();

    save();
}

QString AsemanAutoStartManager::comment() const
{
    return p->comment;
}

void AsemanAutoStartManager::setName(const QString &name)
{
    if(p->name == name)
        return;

    p->name = name;
    emit nameChanged();

    save();
}

QString AsemanAutoStartManager::name() const
{
    return p->name;
}

void AsemanAutoStartManager::setType(const QString &t)
{
    if(p->type == t)
        return;

    p->type = t;
    emit typeChanged();

    save();
}

QString AsemanAutoStartManager::type() const
{
    return p->type;
}

void AsemanAutoStartManager::setActive(bool active)
{
    if(p->active == active)
        return;

    p->active = active;
    emit activeChanged();

    save();
}

bool AsemanAutoStartManager::active() const
{
    return p->active;
}

void AsemanAutoStartManager::refresh()
{
#ifdef Q_OS_LINUX
    const QString &pathDir = QDir::homePath() + "/.config/autostart";
    const QString &path = pathDir + "/" + p->source + ".desktop";

    QDir().mkpath(pathDir);

    QFile file(path);
    if(!file.open(QFile::ReadOnly))
        return;

    const QString data = file.readAll();
    p->active = !data.contains("Hidden=true");

    emit activeChanged();
#endif
}

void AsemanAutoStartManager::save()
{
#ifdef Q_OS_LINUX
    const QString &pathDir = QDir::homePath() + "/.config/autostart";
    const QString &path = pathDir + "/" + p->source + ".desktop";

    QDir().mkpath(pathDir);

    QString data = QString("[Desktop Entry]") +
            "\nHidden=" + (p->active?"false":"true") +
            "\nX-GNOME-Autostart-enabled=" + (p->active?"true":"false") +
            "\nName=" + p->name +
            "\nName[en_US]=" + p->name +
            "\nComment=" + p->comment +
            "\nComment[en_US]=" + p->comment +
            "\nType=" + p->type +
            "\nExec=" + p->command +
            "\nNoDisplay=false\n";

    QFile file(path);
    if(!file.open(QFile::WriteOnly))
        return;

    file.write(data.toUtf8());
    file.close();
#endif
}

AsemanAutoStartManager::~AsemanAutoStartManager()
{
    delete p;
}

