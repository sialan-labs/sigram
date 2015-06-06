#include "asemanunitytaskbarbuttonengine.h"

#ifdef QT_DBUS_LIB
#include <QtDBus>
#endif
#include <QCoreApplication>

AsemanUnityTaskbarButtonEngine::AsemanUnityTaskbarButtonEngine() :
    _badge_number(0),
    _progress(0),
    _launcher("application://" + QCoreApplication::applicationName() + ".desktop")
{
}

void AsemanUnityTaskbarButtonEngine::updateBadgeNumber(int number)
{
    _badge_number = number;
    update(_launcher ,_badge_number, _progress, false);
}

void AsemanUnityTaskbarButtonEngine::updateProgress(qreal progress)
{
    _progress = progress;
    update(_launcher ,_badge_number, _progress, false);
}

void AsemanUnityTaskbarButtonEngine::updateLauncher(const QString &launcher)
{
    if(_launcher == launcher)
        return;
    if(!_launcher.isEmpty() && (_badge_number || _progress))
        update(_launcher ,0, 0, false);

    _launcher = launcher;
    update(_launcher ,_badge_number, _progress, false);
}

void AsemanUnityTaskbarButtonEngine::userAttention()
{
    update(_launcher ,_badge_number, _progress, true);
}

void AsemanUnityTaskbarButtonEngine::update(const QString &launcher, qint64 badgeNumber, qreal progress, bool userAttention)
{
#ifdef QT_DBUS_LIB
    QDBusMessage signal = QDBusMessage::createSignal(
     "/",
     "com.canonical.Unity.LauncherEntry",
     "Update");

    signal << launcher; // "application://cutegram.desktop"

    QVariantMap setProperty;
    setProperty.insert("count", badgeNumber);
    setProperty.insert("count-visible", badgeNumber != 0);
    setProperty.insert("progress", progress/100);
    setProperty.insert("progress-visible", progress != 0);
    setProperty.insert("urgent", userAttention);

    signal << setProperty;
    QDBusConnection::sessionBus().send(signal);
#else
    Q_UNUSED(launcher)
    Q_UNUSED(badgeNumber)
    Q_UNUSED(progress)
#endif
}
