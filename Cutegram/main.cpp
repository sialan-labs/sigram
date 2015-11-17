#define ABOUT_TEXT "Cutegram is a free and opensource telegram clients, released under the GPLv3 license."

#include "asemantools/asemanapplication.h"
#include "asemantools/asemanlistrecord.h"
#include "cutegram.h"
#include "compabilitytools.h"
#include "telegramqmlinitializer.h"
#include "authsaver.h"

#include <QMainWindow>
#include <QPalette>
#include <QNetworkProxy>
#include <QCommandLineParser>

#include <core/settings.h>

int main(int argc, char *argv[])
{
    TelegramQmlInitializer::init("TelegramQmlLib");

    AsemanApplication app(argc, argv);
    app.setApplicationName("Cutegram");
    app.setApplicationDisplayName("Cutegram");
    app.setApplicationVersion("2.7.1");
    app.setOrganizationDomain("land.aseman");
    app.setOrganizationName("Aseman");
    app.setWindowIcon(QIcon(":/qml/Cutegram/files/icon.png"));
    app.setQuitOnLastWindowClosed(false);

#ifdef KWALLET_PRESENT
    QCommandLineOption disKWalletOption(QStringList() << "disable-kwallet",
            QCoreApplication::translate("main", "Disable kwallet."));
#endif
    QCommandLineOption verboseOption(QStringList() << "V" << "verbose",
            QCoreApplication::translate("main", "Verbose Mode."));
    QCommandLineOption forceOption(QStringList() << "f" << "force",
            QCoreApplication::translate("main", "Force to run multiple instance of Cutegram."));
    QCommandLineOption forceVisibleOption(QStringList() << "visible",
            QCoreApplication::translate("main", "Force visible at start"));
    QCommandLineOption dcIdOption(QStringList() << "dc-id",
            QCoreApplication::translate("main", "Sets default DC ID to <id>"), "id");
    QCommandLineOption ipAdrsOption(QStringList() << "ip-address",
            QCoreApplication::translate("main", "Sets default IP Address to <ip>"), "ip");
    QCommandLineOption portableOption(QStringList() << "portable",
            QCoreApplication::translate("main", "Start in the portable mode."));

    QCommandLineParser parser;
    parser.setApplicationDescription(ABOUT_TEXT);
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOption(forceOption);
    parser.addOption(forceVisibleOption);
    parser.addOption(verboseOption);
    parser.addOption(dcIdOption);
    parser.addOption(ipAdrsOption);
    parser.addOption(portableOption);
#ifdef KWALLET_PRESENT
    parser.addOption(disKWalletOption);
#endif
    parser.process(app.arguments());

    if(parser.isSet(portableOption))
        AsemanApplication::setHomePath(AsemanApplication::applicationDirPath() + "/data");

    if(!parser.isSet(verboseOption))
        qputenv("QT_LOGGING_RULES", "tg.*=false");
    else
        qputenv("QT_LOGGING_RULES", "tg.core.settings=false\n"
                                    "tg.core.outboundpkt=false\n"
                                    "tg.core.inboundpkt=false");

#ifndef QT_DEBUG // Disabled because of the debugger bug!!
    if(app.readSetting("Proxy/enable",false).toBool())
    {
        const int type = app.readSetting("Proxy/type",QNetworkProxy::HttpProxy).toInt();
        const QString host = app.readSetting("Proxy/host").toString();
        const quint16 port = app.readSetting("Proxy/port").toInt();
        const QString user = app.readSetting("Proxy/user").toString();
        const QString pass = app.readSetting("Proxy/pass").toString();

        QNetworkProxy proxy;
        proxy.setType( static_cast<QNetworkProxy::ProxyType>(type) );
        proxy.setHostName(host);
        proxy.setPort(port);
        proxy.setUser(user);
        proxy.setPassword(pass);
        QNetworkProxy::setApplicationProxy(proxy);
    }
#endif

#ifdef Q_OS_MAC
    QPalette palette;
    palette.setColor(QPalette::Highlight, "#0d80ec");
    palette.setColor(QPalette::HighlightedText, "#ffffff");
    app.setPalette(palette);
#endif

#ifdef DESKTOP_DEVICE
    if( !parser.isSet(forceOption) && app.isRunning() )
    {
        QStringList args = app.arguments();
        if(args.count() <= 1)
            args << "show";

        AsemanListRecord record;
        for(int i=1; i<args.length(); i++)
            record << args.at(i).toUtf8();

        app.sendMessage(record.toQByteArray());
        return 0;
    }
#endif

    CompabilityTools::version1();

    Cutegram cutegram;
    if(parser.isSet(dcIdOption))
        cutegram.setDefaultHostDcId(parser.value(dcIdOption).toInt());
    if(parser.isSet(ipAdrsOption))
        cutegram.setDefaultHostAddress(parser.value(ipAdrsOption));
#ifdef KWALLET_PRESENT
    if(!parser.isSet(portableOption) && (!parser.isSet(disKWalletOption) || cutegram.kWallet()))
    {
        Settings::setAuthConfigMethods(CutegramAuth::cutegramReadKWalletAuth,
                                       CutegramAuth::cutegramWriteKWalletAuth);
        cutegram.setEncrypterKey(CutegramAuth::readEncryptKeyFromKWallet());
    }
    else
#endif
    {
        Settings::setAuthConfigMethods(CutegramAuth::cutegramReadSerpentAuth,
                                       CutegramAuth::cutegramWriteSerpentAuth);
        cutegram.setEncrypterKey(CutegramAuth::readEncryptKey());
    }

    cutegram.start( parser.isSet(forceOption) || parser.isSet(forceVisibleOption) );

#ifdef DESKTOP_DEVICE
    QObject::connect( &app, SIGNAL(messageReceived(QString)), &cutegram, SLOT(incomingAppMessage(QString)) );
    QObject::connect( &app, SIGNAL(clickedOnDock())         , &cutegram, SLOT(active())                    );
#endif

    return app.exec();
}
