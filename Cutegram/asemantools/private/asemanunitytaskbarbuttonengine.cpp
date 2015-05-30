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
    update(_launcher ,_badge_number, _progress);
}

void AsemanUnityTaskbarButtonEngine::updateProgress(qreal progress)
{
    _progress = progress;
    update(_launcher ,_badge_number, _progress);
}

void AsemanUnityTaskbarButtonEngine::updateLauncher(const QVariant &launcher)
{
    if(_launcher == launcher)
        return;
    if(!_launcher.isEmpty() && (_badge_number || _progress))
        update(_launcher ,0, 0);

    _launcher = launcher.toString();
    update(_launcher ,_badge_number, _progress);
}

void AsemanUnityTaskbarButtonEngine::update(const QString &launcher, qint64 badgeNumber, qreal progress)
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
    setProperty.insert("urgent",false);

    signal << setProperty;
    QDBusConnection::sessionBus().send(signal);
#else
    Q_UNUSED(launcher)
    Q_UNUSED(badgeNumber)
    Q_UNUSED(progress)
#endif
}
