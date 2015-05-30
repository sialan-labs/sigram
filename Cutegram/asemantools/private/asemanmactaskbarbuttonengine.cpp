#include "asemanmactaskbarbuttonengine.h"

#ifdef QT_MACEXTRAS_LIB
#include <QtMac>
#endif

void AsemanMacTaskbarButtonEngine::updateBadgeNumber(int number)
{
#ifdef QT_MACEXTRAS_LIB
    QtMac::setBadgeLabelText(number?QString::number(number):"");
#else
    Q_UNUSED(number)
#endif
}

void AsemanMacTaskbarButtonEngine::updateProgress(qreal progress)
{
    Q_UNUSED(progress)
}
