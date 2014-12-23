#include "asemantools/asemanapplication.h"
#include "asemantools/asemanquickview.h"

#include "cutegram.h"

int main(int argc, char *argv[])
{
    qputenv("QT_LOGGING_RULES", "tg.*=false");

    AsemanApplication app(argc, argv);
    app.setApplicationName("Cutegram");
    app.setApplicationDisplayName("Cutegram");
    app.setOrganizationDomain("org.aseman.cutegram");
    app.setOrganizationName("Aseman");
    app.setWindowIcon(QIcon(app.applicationDirPath()+"/qml/Cutegram/files/papyrus.png"));
    app.setQuitOnLastWindowClosed(false);

#ifdef DESKTOP_DEVICE
    if( app.isRunning() )
    {
        app.sendMessage("show");
        return 0;
    }
#endif

    Cutegram cutegram;
    cutegram.start();

#ifdef DESKTOP_DEVICE
    QObject::connect( &app, SIGNAL(messageReceived(QString)), &cutegram, SLOT(incomingAppMessage(QString)) );
#endif

    return app.exec();
}
