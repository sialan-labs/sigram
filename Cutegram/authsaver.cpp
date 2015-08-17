#define WALLET_FOLDER "Cutegram"

#include "authsaver.h"
#include "simpleqtcryptor/simpleqtcryptor.h"

#include <QByteArray>
#include <QBuffer>
#include <QDataStream>
#include <QProcess>
#include <QThread>
#include <QDir>
#include <QFile>

#include <util/utils.h>

#define SERPENT_PASSWORD(EXTRA) QString(get_hostid() + "-" + EXTRA)

QProcess *cg_wallet_custom_process = 0;

QString get_hostid()
{
    static QString cg_hostId;
    if(!cg_hostId.isEmpty())
        return cg_hostId;

    QProcess prc;
    prc.start("hostid");
    prc.waitForStarted();
    prc.waitForReadyRead();
    prc.waitForFinished();

    cg_hostId = prc.readAll();
    cg_hostId = cg_hostId.trimmed();
    return cg_hostId;
}

bool encryptData(const QByteArray &src, QByteArray &dst, const QString &phone)
{
    QSharedPointer<SimpleQtCryptor::Key> gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(SERPENT_PASSWORD(phone)));
    SimpleQtCryptor::Encryptor enc( gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB, SimpleQtCryptor::NoChecksum );
    if(enc.encrypt( src, dst, true ) != SimpleQtCryptor::NoError)
        return false;
    else
        return true;
}

bool decryptData(const QByteArray &src, QByteArray &dst, const QString &phone)
{
    QSharedPointer<SimpleQtCryptor::Key> gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(SERPENT_PASSWORD(phone)));
    SimpleQtCryptor::Decryptor dec( gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB );
    if(dec.decrypt( src, dst, true ) != SimpleQtCryptor::NoError)
        return false;
    else
        return true;
}

#if defined(KWALLET_PRESENT)
#include "asemantools/asemankdewallet.h"

AsemanKdeWallet *cg_wallet = 0;
bool cg_wallet_failed = false;
bool cg_wallet_tried_run = false;

bool init_kwallet_connection()
{
    if(cg_wallet_failed)
        return false;
    if(cg_wallet)
        return true;

    cg_wallet = new AsemanKdeWallet();
    const QStringList &wallets = cg_wallet->availableWallets();
    if(wallets.isEmpty())
        return false;
    if(wallets.contains("kdewallet"))
        cg_wallet->setWallet("kdewallet");
    else
        cg_wallet->setWallet(wallets.first());

    if(!cg_wallet->open())
    {
        cg_wallet_failed = true;
        delete cg_wallet;
        cg_wallet = 0;
        return false;
    }

    if(!cg_wallet->hasFolder(WALLET_FOLDER))
        cg_wallet->createFolder(WALLET_FOLDER);

    return true;
}

bool init_kwallet()
{
    if(init_kwallet_connection())
        return true;
    if(cg_wallet_tried_run)
        return false;

    cg_wallet_custom_process = new QProcess();
    cg_wallet_custom_process->start("kwalletd");
    cg_wallet_custom_process->waitForStarted();
    if(cg_wallet_custom_process->processId())
    {
        cg_wallet_custom_process->waitForReadyRead();
        QThread::msleep(3000);
    }
    else
        delete cg_wallet_custom_process;

    cg_wallet_failed = false;
    cg_wallet_tried_run = true;

    return init_kwallet_connection();
}

bool CutegramAuth::cutegramReadKWalletAuth(const QString &configPath, const QString &phone, QVariantMap &map)
{
    Q_UNUSED(configPath)
    if(!init_kwallet())
        return cutegramReadSerpentAuth(configPath, phone, map);

    QByteArray data;
    QByteArray enc_data = cg_wallet->readEntry(WALLET_FOLDER, phone);
    if(!decryptData(enc_data, data, phone))
        return false;

    QDataStream stream(&data, QIODevice::ReadOnly);
    stream >> map;

    return true;
}

bool CutegramAuth::cutegramWriteKWalletAuth(const QString &configPath, const QString &phone, const QVariantMap &map)
{
    Q_UNUSED(configPath)
    if(!init_kwallet())
        return cutegramWriteSerpentAuth(configPath, phone, map);

    QByteArray data;
    QDataStream stream(&data, QIODevice::WriteOnly);
    stream << map;

    QByteArray enc_data;
    if(!encryptData(data, enc_data, phone))
        return false;

    cg_wallet->writeEntry(WALLET_FOLDER, phone, enc_data);

    return true;
}
#endif


QString telegram_serpent_auth_path(const QString &configPath, const QString &phone)
{
    const QString phoneNumber = Utils::parsePhoneNumberDigits(phone);
    const QString pathDir = configPath + "/" + phoneNumber;

    QDir().mkpath(pathDir);
    return pathDir + "/auth.cg";
}

bool CutegramAuth::cutegramReadSerpentAuth(const QString &configPath, const QString &phone, QVariantMap &map)
{
    const QString &authPath = telegram_serpent_auth_path(configPath, phone);
    if(!QFile::exists(authPath))
        return true;
    QFile file(authPath);
    if(!file.open(QFile::ReadOnly))
        return false;

    QByteArray data;
    QByteArray enc_data = file.readAll();
    if(!decryptData(enc_data, data, phone))
        return false;

    QDataStream stream(&data, QIODevice::ReadOnly);
    stream >> map;
    return true;
}

bool CutegramAuth::cutegramWriteSerpentAuth(const QString &configPath, const QString &phone, const QVariantMap &map)
{
    const QString &authPath = telegram_serpent_auth_path(configPath, phone);
    QByteArray data;
    QDataStream stream(&data, QIODevice::WriteOnly);
    stream << map;

    QByteArray enc_data;
    if(!encryptData(data, enc_data, phone))
        return false;

    QFile file(authPath);
    if(!file.open(QFile::WriteOnly))
        return false;

    file.write(enc_data);
    file.close();
    return true;
}
