#ifndef ASEMANTOOLSPLUGIN_H
#define ASEMANTOOLSPLUGIN_H

#include <QQmlExtensionPlugin>

class AsemanToolsPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
};

#endif // ASEMANTOOLSPLUGIN_H
