#include "asemantaskbarbutton.h"
#include "private/asemanabstracttaskbarbuttonengine.h"

#include <QDebug>

#ifdef Q_OS_WIN
#include "private/asemanwintaskbarbuttonengine.h"
#else
#ifdef Q_OS_MAC
#include "private/asemanmactaskbarbuttonengine.h"
#else
#if defined(Q_OS_LINUX) && defined(QT_DBUS_LIB)
#include "private/asemanunitytaskbarbuttonengine.h"
#else
#include "private/asemanabstracttaskbarbuttonengine.h"
class AsemanNullTaskbarButtonEngine: public AsemanAbstractTaskbarButtonEngine
{
public:
    void updateBadgeNumber(int number){Q_UNUSED(number)}
    void updateProgress(qreal progress){Q_UNUSED(progress)}
};
#endif
#endif
#endif

class AsemanTaskbarButtonPrivate
{
public:
    int badgeNumber;
    qreal progress;
    QString launcher;
    AsemanAbstractTaskbarButtonEngine *engine;
    QWindow *window;
};

AsemanTaskbarButton::AsemanTaskbarButton(QObject *parent) :
    QObject(parent)
{
    p = new AsemanTaskbarButtonPrivate;
    p->badgeNumber = 0;
    p->progress = 0;
    p->window = 0;

#ifdef Q_OS_WIN
    p->engine = new AsemanWinTaskbarButtonEngine();
#else
#ifdef Q_OS_MAC
    p->engine = new AsemanMacTaskbarButtonEngine();
#else
#if defined(Q_OS_LINUX) && defined(QT_DBUS_LIB)
    p->engine = new AsemanUnityTaskbarButtonEngine();
#else
    p->engine = new AsemanNullTaskbarButtonEngine();
#endif
#endif
#endif
}

void AsemanTaskbarButton::setBadgeNumber(int num)
{
    if(p->badgeNumber == num)
        return;

    p->badgeNumber = num;
    p->engine->updateBadgeNumber(num);
    emit badgeNumberChanged();
}

int AsemanTaskbarButton::badgeNumber() const
{
    return p->badgeNumber;
}

void AsemanTaskbarButton::setProgress(qreal progress)
{
    if(p->progress == progress)
        return;

    p->progress = progress;
    p->engine->updateProgress(progress);
    emit progressChanged();
}

qreal AsemanTaskbarButton::progress() const
{
    return p->progress;
}

void AsemanTaskbarButton::setLauncher(const QString &launcher)
{
    if(p->launcher == launcher)
        return;

    p->launcher = launcher;
    p->engine->updateLauncher(p->launcher);
    emit launcherChanged();
}

QString AsemanTaskbarButton::launcher() const
{
    return p->launcher;
}

void AsemanTaskbarButton::setWindow(QWindow *win)
{
    if(p->window == win)
        return;

    p->window = win;
    p->engine->updateWindow(p->window);
    emit windowChanged();
}

QWindow *AsemanTaskbarButton::window() const
{
    return p->window;
}

void AsemanTaskbarButton::userAttention()
{
    p->engine->userAttention();
}

AsemanTaskbarButton::~AsemanTaskbarButton()
{
    delete p->engine;
    delete p;
}

