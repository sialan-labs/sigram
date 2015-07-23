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
#include "asemanfilesystemmodel.h"
#include "asemanquickobject.h"
#include "asemannotification.h"
#include "asemanfiledownloaderqueueitem.h"
#include "asemanquickitemimagegrabber.h"
#include "asemanwebpagegrabber.h"
#include "asemantitlebarcolorgrabber.h"
#include "asemanfiledownloaderqueue.h"
#include "asemantaskbarbutton.h"
#include "asemanmapdownloader.h"
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
#ifdef ASEMAN_MULTIMEDIA
#include "asemanaudiorecorder.h"
#include "asemanaudioencodersettings.h"
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

    qmlRegisterType<AsemanMimeData>("AsemanTools", 1, 0, "MimeData");
    qmlRegisterType<AsemanDragObject>("AsemanTools", 1, 0, "DragObject");
    qmlRegisterType<AsemanHashObject>("AsemanTools", 1,0, "HashObject");
    qmlRegisterType<AsemanListObject>("AsemanTools", 1,0, "ListObject");
    qmlRegisterType<AsemanDownloader>("AsemanTools", 1,0, "Downloader");
    qmlRegisterType<AsemanQuickObject>("AsemanTools", 1,0, "AsemanObject");
    qmlRegisterType<AsemanImageColorAnalizor>("AsemanTools", 1,0, "ImageColorAnalizor");
    qmlRegisterType<AsemanCountriesModel>("AsemanTools", 1,0, "CountriesModel");
    qmlRegisterType<AsemanNotification>("AsemanTools", 1,0, "Notification");
    qmlRegisterType<AsemanFileSystemModel>("AsemanTools", 1,0, "FileSystemModel");
    qmlRegisterType<AsemanAutoStartManager>("AsemanTools", 1,0, "AutoStartManager");
    qmlRegisterType<AsemanQuickItemImageGrabber>("AsemanTools", 1,0, "ItemImageGrabber");
    qmlRegisterType<AsemanFileDownloaderQueueItem>("AsemanTools", 1,0, "FileDownloaderQueueItem");
    qmlRegisterType<AsemanFileDownloaderQueue>("AsemanTools", 1,0, "FileDownloaderQueue");
    qmlRegisterType<AsemanMimeApps>("AsemanTools", 1,0, "MimeApps");
    qmlRegisterType<AsemanWebPageGrabber>("AsemanTools", 1,0, "WebPageGrabber");
    qmlRegisterType<AsemanTitleBarColorGrabber>("AsemanTools", 1,0, "TitleBarColorGrabber");
    qmlRegisterType<AsemanTaskbarButton>("AsemanTools", 1,0, "TaskbarButton");
    qmlRegisterType<AsemanMapDownloader>("AsemanTools", 1,0, "MapDownloader");

#ifdef ASEMAN_SENSORS
    qmlRegisterType<AsemanSensors>("AsemanTools", 1,0, "AsemanSensors");
#endif
#ifdef ASEMAN_MULTIMEDIA
    qmlRegisterType<AsemanAudioRecorder>("AsemanTools", 1,0, "AudioRecorder");
    qmlRegisterType<AsemanAudioEncoderSettings>("AsemanTools", 1,0, "AudioEncoderSettings");
#endif

    qmlRegisterUncreatableType<AsemanDesktopTools>("AsemanTools", 1,0, "AsemanDesktopTools", "It's a singleton class");

    qmlRegisterSingletonType<AsemanDevices>(uri, 1, 0, "Devices", aseman_devices_singleton);
    qmlRegisterSingletonType<AsemanTools>(uri, 1, 0, "Tools", aseman_tools_singleton);
    qmlRegisterSingletonType<AsemanDesktopTools>(uri, 1, 0, "Desktop", aseman_desktoptools_singleton);
    qmlRegisterSingletonType<AsemanCalendarConverter>(uri, 1, 0, "CalendarConv", aseman_calendarconv_singleton);
    qmlRegisterSingletonType<AsemanBackHandler>(uri, 1, 0, "BackHandler", aseman_backhandler_singleton);
    qmlRegisterSingletonType<AsemanApplication>(uri, 1, 0, "AsemanApp", aseman_app_singleton);
    qmlRegisterSingletonType<AsemanQtLogger>(uri, 1, 0, "Logger", aseman_logger_singleton);
    qmlRegisterSingletonType<AsemanQuickView>(uri, 1, 0, "View", aseman_qview_singleton);
}
