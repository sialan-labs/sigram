#ifndef ASEMANMACTASKBARBUTTONENGINE_H
#define ASEMANMACTASKBARBUTTONENGINE_H

#include "asemanabstracttaskbarbuttonengine.h"

class AsemanMacTaskbarButtonEngine : public AsemanAbstractTaskbarButtonEngine
{
public:
    void updateBadgeNumber(int number);
    void updateProgress(qreal progress);
    void updateLauncher(const QVariant &launcher);
};

#endif // ASEMANMACTASKBARBUTTONENGINE_H
