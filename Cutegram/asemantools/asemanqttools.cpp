#include "asemanqttools.h"

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
#include "asemanfonthandler.h"
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
#include "asemandragarea.h"
#include "asemancalendarmodel.h"
#include "asemanquickviewwrapper.h"
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
#if defined(Q_OS_LINUX) && defined(QT_DBUS_LIB)
#include "asemankdewallet.h"
#endif

#include <qqml.h>
#include <QHash>

#define SINGLETON_PROVIDER(TYPE, FNC_NAME, NEW_CREATOR) \
    static QObject *FNC_NAME(QQmlEngine *engine, QJSEngine *scriptEngine) { \
        Q_UNUSED(engine) \
        Q_UNUSED(scriptEngine) \
        static TYPE *singleton = NEW_CREATOR; \
        return singleton; \
    }

SINGLETON_PROVIDER(AsemanDevices          , aseman_devices_singleton     , AsemanQtTools::devices())
SINGLETON_PROVIDER(AsemanTools            , aseman_tools_singleton       , AsemanQtTools::tools())
SINGLETON_PROVIDER(AsemanDesktopTools     , aseman_desktoptools_singleton, AsemanQtTools::desktopTools())
SINGLETON_PROVIDER(AsemanCalendarConverter, aseman_calendarconv_singleton, AsemanQtTools::calendar(engine))
SINGLETON_PROVIDER(AsemanBackHandler      , aseman_backhandler_singleton , AsemanQtTools::backHandler(engine))
SINGLETON_PROVIDER(AsemanApplication      , aseman_app_singleton         , AsemanQtTools::application())
SINGLETON_PROVIDER(AsemanQuickViewWrapper , aseman_qview_singleton       , AsemanQtTools::quickView(engine))
SINGLETON_PROVIDER(AsemanQtLogger         , aseman_logger_singleton      , AsemanQtTools::qtLogger())

void AsemanQtTools::registerTypes(const char *uri)
{
    static QSet<QByteArray> register_list;
    if(register_list.contains(uri))
        return;

    qRegisterMetaType<AsemanMimeData*>("AsemanMimeData*");

    qmlRegisterType<AsemanMimeData>(uri, 1, 0, "MimeData");
    qmlRegisterType<AsemanDragObject>(uri, 1, 0, "DragObject");
    qmlRegisterType<AsemanHashObject>(uri, 1,0, "HashObject");
    qmlRegisterType<AsemanListObject>(uri, 1,0, "ListObject");
    qmlRegisterType<AsemanDownloader>(uri, 1,0, "Downloader");
    qmlRegisterType<AsemanQuickObject>(uri, 1,0, "AsemanObject");
    qmlRegisterType<AsemanImageColorAnalizor>(uri, 1,0, "ImageColorAnalizor");
    qmlRegisterType<AsemanCountriesModel>(uri, 1,0, "CountriesModel");
    qmlRegisterType<AsemanNotification>(uri, 1,0, "Notification");
    qmlRegisterType<AsemanFileSystemModel>(uri, 1,0, "FileSystemModel");
    qmlRegisterType<AsemanAutoStartManager>(uri, 1,0, "AutoStartManager");
    qmlRegisterType<AsemanQuickItemImageGrabber>(uri, 1,0, "ItemImageGrabber");
    qmlRegisterType<AsemanFileDownloaderQueueItem>(uri, 1,0, "FileDownloaderQueueItem");
    qmlRegisterType<AsemanFileDownloaderQueue>(uri, 1,0, "FileDownloaderQueue");
    qmlRegisterType<AsemanFontHandler>(uri, 1,0, "FontHandler");
#ifdef DESKTOP_LINUX
    qmlRegisterType<AsemanMimeApps>(uri, 1,0, "MimeApps");
#endif
    qmlRegisterType<AsemanWebPageGrabber>(uri, 1,0, "WebPageGrabber");
    qmlRegisterType<AsemanTitleBarColorGrabber>(uri, 1,0, "TitleBarColorGrabber");
    qmlRegisterType<AsemanTaskbarButton>(uri, 1,0, "TaskbarButton");
    qmlRegisterType<AsemanMapDownloader>(uri, 1,0, "MapDownloader");
    qmlRegisterType<AsemanDragArea>(uri, 1,0, "MouseDragArea");
    qmlRegisterType<AsemanCalendarModel>(uri, 1,0, "CalendarModel");
#if defined(Q_OS_LINUX) && defined(QT_DBUS_LIB)
    qmlRegisterType<AsemanKdeWallet>(uri, 1,0, "KdeWallet");
#endif

#ifdef ASEMAN_SENSORS
    qmlRegisterType<AsemanSensors>(uri, 1,0, "AsemanSensors");
#endif
#ifdef ASEMAN_MULTIMEDIA
    qmlRegisterType<AsemanAudioRecorder>(uri, 1,0, "AudioRecorder");
    qmlRegisterType<AsemanAudioEncoderSettings>(uri, 1,0, "AudioEncoderSettings");
#endif

    qmlRegisterUncreatableType<AsemanDesktopTools>(uri, 1,0, "AsemanDesktopTools", "It's a singleton class");

    qmlRegisterSingletonType<AsemanDevices>(uri, 1, 0, "Devices", aseman_devices_singleton);
    qmlRegisterSingletonType<AsemanTools>(uri, 1, 0, "Tools", aseman_tools_singleton);
    qmlRegisterSingletonType<AsemanDesktopTools>(uri, 1, 0, "Desktop", aseman_desktoptools_singleton);
    qmlRegisterSingletonType<AsemanCalendarConverter>(uri, 1, 0, "CalendarConv", aseman_calendarconv_singleton);
    qmlRegisterSingletonType<AsemanBackHandler>(uri, 1, 0, "BackHandler", aseman_backhandler_singleton);
    qmlRegisterSingletonType<AsemanApplication>(uri, 1, 0, "AsemanApp", aseman_app_singleton);
    qmlRegisterSingletonType<AsemanQtLogger>(uri, 1, 0, "Logger", aseman_logger_singleton);
    qmlRegisterSingletonType<AsemanQuickViewWrapper>(uri, 1, 0, "View", aseman_qview_singleton);

    register_list.insert(uri);
}

AsemanQuickViewWrapper *AsemanQtTools::quickView(QQmlEngine *engine)
{
    static QHash<QQmlEngine*, QPointer<AsemanQuickViewWrapper> > views;
    AsemanQuickViewWrapper *res = views.value(engine);
    if(res)
        return res;

#ifdef ASEMAN_QML_PLUGIN
    AsemanQuickView *view = new AsemanQuickView(engine, engine);
#else
    AsemanQuickView *view = qobject_cast<AsemanQuickView*>(engine->parent());
#endif

    if(view)
    {
        res = new AsemanQuickViewWrapper(view, engine);
        views[engine] = res;
        return res;
    }

    return res;
}

AsemanApplication *AsemanQtTools::application()
{
//    AsemanApplication *res = AsemanApplication::instance();
//    if(res)
//        return res;
//    if(QCoreApplication::instance() == 0)
//        return 0;

    static QPointer<AsemanApplication> res;
    if(!res)
        res = new AsemanApplication();

    return res;
}

AsemanDesktopTools *AsemanQtTools::desktopTools()
{
    static QPointer<AsemanDesktopTools> res = 0;
    if(!res)
        res = new AsemanDesktopTools();

    return res;
}

AsemanDevices *AsemanQtTools::devices()
{
    static QPointer<AsemanDevices> res = 0;
    if(!res)
        res = new AsemanDevices();

    return res;
}

AsemanQtLogger *AsemanQtTools::qtLogger()
{
    static QPointer<AsemanQtLogger> res = 0;
    if(!res)
        res = new AsemanQtLogger(AsemanApplication::logPath());

    return res;
}

AsemanTools *AsemanQtTools::tools()
{
    static QPointer<AsemanTools> res = 0;
    if(!res)
        res = new AsemanTools();

    return res;
}

AsemanCalendarConverter *AsemanQtTools::calendar(QQmlEngine *engine)
{
    static QHash<QQmlEngine*, QPointer<AsemanCalendarConverter> > views;
    AsemanCalendarConverter *res = views.value(engine);
    if(res)
        return res;

    res = new AsemanCalendarConverter();
    views[engine] = res;
    return res;
}

AsemanBackHandler *AsemanQtTools::backHandler(QQmlEngine *engine)
{
    static QHash<QQmlEngine*, QPointer<AsemanBackHandler> > views;
    AsemanBackHandler *res = views.value(engine);
    if(res)
        return res;

    res = new AsemanBackHandler();
    views[engine] = res;
    return res;
}
