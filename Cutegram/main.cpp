#define ABOUT_TEXT "Cutegram is a free and opensource telegram clients, released under the GPLv3 license."

#include "asemantools/asemanapplication.h"
#include "cutegram.h"
#include "telegramtestobject.h"
#include "compabilitytools.h"

#include <QMainWindow>
#include <QPalette>
#include <QNetworkProxy>
#include <QCommandLineParser>

#include <telegram.h>

int main(int argc, char *argv[])
{
    AsemanApplication app(argc, argv);
    app.setApplicationName("Cutegram");
    app.setApplicationDisplayName("Cutegram");
    app.setApplicationVersion("2.3.1");
    app.setOrganizationDomain("land.aseman");
    app.setOrganizationName("Aseman");
    app.setWindowIcon(QIcon(":/qml/Cutegram/files/icon.png"));
    app.setQuitOnLastWindowClosed(false);

    QCommandLineOption verboseOption(QStringList() << "V" << "verbose",
            QCoreApplication::translate("main", "Verbose Mode."));
    QCommandLineOption forceOption(QStringList() << "f" << "force",
            QCoreApplication::translate("main", "Force to run multiple instance of Cutegram."));

    QCommandLineParser parser;
    parser.setApplicationDescription(ABOUT_TEXT);
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOption(forceOption);
    parser.addOption(verboseOption);
    parser.process(app);

    if(!parser.isSet(verboseOption))
        qputenv("QT_LOGGING_RULES", "tg.*=false");

    Telegram::setDefaultHostAddress("149.154.167.50");
    Telegram::setDefaultHostPort(443);
    Telegram::setDefaultHostDcId(2);
    Telegram::setAppId(13682);
    Telegram::setAppHash("de37bcf00f4688de900510f4f87384bb");

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
    cutegram.start();

#ifdef DESKTOP_DEVICE
    QObject::connect( &app, SIGNAL(messageReceived(QString)), &cutegram, SLOT(incomingAppMessage(QString)) );
    QObject::connect( &app, SIGNAL(clickedOnDock())         , &cutegram, SLOT(incomingAppMessage())        );
#endif

    return app.exec();
}
