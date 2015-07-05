
#define ABOUT_TEXT "Cutegram is a free and opensource telegram clients, released under the GPLv3 license."

#include "asemantools/asemanapplication.h"
#include "cutegram.h"
#include "compabilitytools.h"
#include "telegramqmlinitializer.h"

#include <QMainWindow>
#include <QPalette>
#include <QNetworkProxy>
#include <QCommandLineParser>

int main(int argc, char *argv[])
{
    TelegramQmlInitializer::init("TelegramQml");

    AsemanApplication app(argc, argv);
    app.setApplicationName("Cutegram");
    app.setApplicationDisplayName("Cutegram");
    app.setApplicationVersion("2.5.0");
    app.setOrganizationDomain("land.aseman");
    app.setOrganizationName("Aseman");
    app.setWindowIcon(QIcon(":/qml/Cutegram/files/icon.png"));
    app.setQuitOnLastWindowClosed(false);

    QCommandLineOption verboseOption(QStringList() << "V" << "verbose",
            QCoreApplication::translate("main", "Verbose Mode."));
    QCommandLineOption forceOption(QStringList() << "f" << "force",
            QCoreApplication::translate("main", "Force to run multiple instance of Cutegram."));
    QCommandLineOption dcIdOption(QStringList() << "dc-id",
            QCoreApplication::translate("main", "Sets default DC ID to <id>"), "id");
    QCommandLineOption ipAdrsOption(QStringList() << "ip-address",
            QCoreApplication::translate("main", "Sets default IP Address to <ip>"), "ip");

    QCommandLineParser parser;
    parser.setApplicationDescription(ABOUT_TEXT);
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOption(forceOption);
    parser.addOption(verboseOption);
    parser.addOption(dcIdOption);
    parser.addOption(ipAdrsOption);
    parser.process(app);

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
        app.sendMessage("show");
        return 0;
    }
#endif

    CompabilityTools::version1();

    Cutegram cutegram;
    if(parser.isSet(dcIdOption))
        cutegram.setDefaultHostDcId(parser.value(dcIdOption).toInt());
    if(parser.isSet(ipAdrsOption))
        cutegram.setDefaultHostAddress(parser.value(ipAdrsOption));

    cutegram.start( parser.isSet(forceOption) );

#ifdef DESKTOP_DEVICE
    QObject::connect( &app, SIGNAL(messageReceived(QString)), &cutegram, SLOT(incomingAppMessage(QString)) );
    QObject::connect( &app, SIGNAL(clickedOnDock())         , &cutegram, SLOT(incomingAppMessage())        );
#endif

    return app.exec();
}
