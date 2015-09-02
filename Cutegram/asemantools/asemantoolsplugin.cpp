#include "asemantoolsplugin.h"
#include "asemanqttools.h"

void AsemanToolsPlugin::registerTypes(const char *uri)
{
    AsemanQtTools::registerTypes(uri);
}
