#include "asemantools/asemanapplication.h"
#include "asemantools/asemanquickview.h"

#include "cutegram.h"
#include "compabilitytools.h"

int main(int argc, char *argv[])
{
    qputenv("QT_LOGGING_RULES", "tg.*=false");

    AsemanApplication app(argc, argv);
    app.setApplicationName("Cutegram");
    app.setApplicationDisplayName("Cutegram");
    app.setApplicationVersion("v1.0.3");
    app.setOrganizationDomain("land.aseman");
    app.setOrganizationName("Aseman");
    app.setWindowIcon(QIcon(":/qml/Cutegram/files/icon.png"));
    app.setQuitOnLastWindowClosed(false);

#ifdef DESKTOP_DEVICE
    if( !app.arguments().contains("--force") && app.isRunning() )
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
#endif

    return app.exec();
}
