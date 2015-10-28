#ifndef ASEMANQTTOOLS_H
#define ASEMANQTTOOLS_H

#include <QtGlobal>
#include <QString>

class QQmlEngine;
class QJSEngine;
class AsemanQtTools
{
public:
    static void registerTypes(const char *uri);

    static class AsemanQuickViewWrapper *quickView(QQmlEngine *engine);
    static class AsemanApplication *application();
    static class AsemanDesktopTools *desktopTools();
    static class AsemanDevices *devices();
    static class AsemanQtLogger *qtLogger();
    static class AsemanTools *tools();
    static class AsemanCalendarConverter *calendar(QQmlEngine *engine);
    static class AsemanBackHandler *backHandler(QQmlEngine *engine);
};

#endif // ASEMANQTTOOLS_H
