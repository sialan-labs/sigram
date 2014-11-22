#include "sialantools/sialanapplication.h"
#include "sialantools/sialanquickview.h"

#include "sigram.h"

int main(int argc, char *argv[])
{
    qputenv("QT_LOGGING_RULES", "tg.*=false");

    SialanApplication app(argc, argv);
    app.setApplicationName("Sigram");
    app.setApplicationDisplayName("Sigram");
    app.setOrganizationDomain("org.sialan.sigram");
    app.setOrganizationName("Sialan");
    app.setWindowIcon(QIcon(app.applicationDirPath()+"/qml/Sigram/files/kaqaz.png"));
    app.setQuitOnLastWindowClosed(false);

#ifdef DESKTOP_DEVICE
    if( app.isRunning() )
    {
        app.sendMessage("show");
        return 0;
    }
#endif

    Sigram sigram;
    sigram.start();

#ifdef DESKTOP_DEVICE
    QObject::connect( &app, SIGNAL(messageReceived(QString)), &sigram, SLOT(incomingAppMessage(QString)) );
#endif

    return app.exec();
}
