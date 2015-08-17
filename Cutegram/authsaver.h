#ifndef AUTHSAVER_H
#define AUTHSAVER_H

#include <QVariantMap>

namespace CutegramAuth {
#if defined(Q_OS_LINUX) && defined(QT_DBUS_LIB)
#define KWALLET_PRESENT
bool cutegramReadKWalletAuth(const QString &configPath, const QString &phone, QVariantMap &map);
bool cutegramWriteKWalletAuth(const QString &configPath, const QString &phone, const QVariantMap &map);
#endif
bool cutegramReadSerpentAuth(const QString &configPath, const QString &phone, QVariantMap &map);
bool cutegramWriteSerpentAuth(const QString &configPath, const QString &phone, const QVariantMap &map);
}

#endif // AUTHSAVER_H
