#include "asemantoolsplugin.h"
#include "asemanquickview.h"
#include "asemandesktoptools.h"
#include "asemanqtlogger.h"
#include "asemandevices.h"
#include "asemantools.h"
#include "asemanapplication.h"
#include "asemanhashobject.h"
#include "asemandownloader.h"
#include "asemanlistobject.h"
#include "asemancalendarconverter.h"
#include "asemanimagecoloranalizor.h"
#include "asemanmimedata.h"
#include "asemandragobject.h"
#include "asemanbackhandler.h"
#include "aseman_macros.h"
#include "asemancountriesmodel.h"
#include "asemanautostartmanager.h"
#ifdef Q_OS_ANDROID
#include "asemanjavalayer.h"
#endif
#ifdef DESKTOP_LINUX
#include "asemanmimeapps.h"
#endif
#ifdef ASEMAN_SENSORS
#include "asemansensors.h"
#endif
#ifdef ASEMAN_NOTIFICATION
#include "asemannotification.h"
#endif

#include <qqml.h>

#define SINGLETON_PROVIDER(TYPE, FNC_NAME, ...) \
    SINGLETON_PROVIDER_PRO(TYPE, FNC_NAME, new TYPE(__VA_ARGS__))

#define SINGLETON_PROVIDER_PRO(TYPE, FNC_NAME, NEW_CREATOR) \
    static QObject *FNC_NAME(QQmlEngine *engine, QJSEngine *scriptEngine) { \
        Q_UNUSED(engine) \
        Q_UNUSED(scriptEngine) \
        static TYPE *singleton = NEW_CREATOR; \
        return singleton; \
    }

SINGLETON_PROVIDER(AsemanDevices, aseman_devices_singleton)
SINGLETON_PROVIDER(AsemanTools, aseman_tools_singleton)
SINGLETON_PROVIDER(AsemanDesktopTools, aseman_desktoptools_singleton)
SINGLETON_PROVIDER(AsemanCalendarConverter, aseman_calendarconv_singleton)
SINGLETON_PROVIDER(AsemanBackHandler, aseman_backhandler_singleton)
SINGLETON_PROVIDER(AsemanApplication, aseman_app_singleton)
SINGLETON_PROVIDER_PRO(AsemanQuickView, aseman_qview_singleton, new AsemanQuickView(engine))
SINGLETON_PROVIDER_PRO(AsemanQtLogger, aseman_logger_singleton, new AsemanQtLogger(AsemanApplication::logPath()))

void AsemanToolsPlugin::registerTypes(const char *uri)
{
    qRegisterMetaType<AsemanMimeData*>("AsemanMimeData*");

    qmlRegisterType<AsemanMimeData>(uri, 1, 0, "MimeData");
    qmlRegisterType<AsemanDragObject>(uri, 1, 0, "DragObject");
    qmlRegisterType<AsemanListObject>(uri, 1, 0, "ListObject");
    qmlRegisterType<AsemanHashObject>(uri, 1, 0, "HashObject");
    qmlRegisterType<AsemanDownloader>(uri, 1,0, "Downloader");
    qmlRegisterType<AsemanImageColorAnalizor>(uri, 1,0, "ImageColorAnalizor");
    qmlRegisterType<AsemanCountriesModel>(uri, 1,0, "CountriesModel");
    qmlRegisterType<AsemanAutoStartManager>(uri, 1,0, "AutoStartManager");
#ifdef DESKTOP_LINUX
    qmlRegisterType<AsemanMimeApps>(uri, 1,0, "MimeApps");
#endif
#ifdef ASEMAN_SENSORS
    qmlRegisterType<AsemanSensors>(uri, 1,0, "AsemanSensors");
#endif
#ifdef ASEMAN_NOTIFICATION
    qmlRegisterType<AsemanNotification>(uri, 1,0, "Notification");
#endif

    qmlRegisterSingletonType<AsemanDevices>(uri, 1, 0, "Devices", aseman_devices_singleton);
    qmlRegisterSingletonType<AsemanTools>(uri, 1, 0, "Tools", aseman_tools_singleton);
    qmlRegisterSingletonType<AsemanDesktopTools>(uri, 1, 0, "Desktop", aseman_desktoptools_singleton);
    qmlRegisterSingletonType<AsemanCalendarConverter>(uri, 1, 0, "CalendarConv", aseman_calendarconv_singleton);
    qmlRegisterSingletonType<AsemanBackHandler>(uri, 1, 0, "BackHandler", aseman_backhandler_singleton);
    qmlRegisterSingletonType<AsemanApplication>(uri, 1, 0, "AsemanApp", aseman_app_singleton);
    qmlRegisterSingletonType<AsemanQtLogger>(uri, 1, 0, "Logger", aseman_logger_singleton);
    qmlRegisterSingletonType<AsemanQuickView>(uri, 1, 0, "View", aseman_qview_singleton);
}
