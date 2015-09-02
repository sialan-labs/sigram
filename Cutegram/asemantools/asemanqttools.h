#ifndef ASEMANQTTOOLS_H
#define ASEMANQTTOOLS_H

#include <QtGlobal>

class QQmlEngine;
class QJSEngine;
class AsemanQtTools
{
public:
    static void registerTypes(const char *uri);

    static class AsemanQuickView *quickView(QQmlEngine *engine);
    static class AsemanApplication *application();
    static class AsemanDesktopTools *desktopTools();
    static class AsemanDevices *devices();
    static class AsemanQtLogger *qtLogger();
    static class AsemanTools *tools();
#ifdef Q_OS_ANDROID
    static class AsemanJavaLayer *javaLayer();
#endif
    static class AsemanCalendarConverter *calendar(QQmlEngine *engine);
    static class AsemanBackHandler *backHandler(QQmlEngine *engine);
};

#endif // ASEMANQTTOOLS_H
