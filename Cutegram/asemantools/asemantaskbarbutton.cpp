#include "asemantaskbarbutton.h"
#include "private/asemanabstracttaskbarbuttonengine.h"

#ifdef Q_OS_WIN
#include "private/asemanwintaskbarbuttonengine.h"
#else
#ifdef Q_OS_MAC
#include "private/asemanmactaskbarbuttonengine.h"
#else
#ifdef Q_OS_LINUX
#include "private/asemanunitytaskbarbuttonengine.h"
#else
#include "private/asemanabstracttaskbarbuttonengine.h"
class AsemanNullTaskbarButtonEngine: public AsemanAbstractTaskbarButtonEngine
{
public:
    void updateBadgeNumber(int number){Q_UNUSED(number)}
    void updateProgress(qreal progress){Q_UNUSED(progress)}
    void updateLauncher(const QVariant &launcher){Q_UNUSED(launcher)}
};
#endif
#endif
#endif

class AsemanTaskbarButtonPrivate
{
public:
    int badgeNumber;
    qreal progress;
    QVariant launcher;
    AsemanAbstractTaskbarButtonEngine *engine;
};

AsemanTaskbarButton::AsemanTaskbarButton(QObject *parent) :
    QObject(parent)
{
    p = new AsemanTaskbarButtonPrivate;
    p->badgeNumber = 0;
    p->progress = 0;

#ifdef Q_OS_WIN
    p->engine = new AsemanWinTaskbarButtonEngine();
#else
#ifdef Q_OS_MAC
    p->engine = new AsemanMacTaskbarButtonEngine();
#else
#ifdef Q_OS_LINUX
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

void AsemanTaskbarButton::setLauncher(const QVariant &launcher)
{
    if(p->launcher == launcher)
        return;

    p->launcher = launcher;
    emit launcherChanged();
}

QVariant AsemanTaskbarButton::launcher() const
{
    return p->launcher;
}

AsemanTaskbarButton::~AsemanTaskbarButton()
{
    delete p->engine;
    delete p;
}

