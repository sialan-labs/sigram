#ifndef ASEMANABSTRACTTASKBARBUTTONENGINE_H
#define ASEMANABSTRACTTASKBARBUTTONENGINE_H

#include <QtGlobal>
#include <QVariant>

class AsemanAbstractTaskbarButtonEngine
{
public:
    virtual ~AsemanAbstractTaskbarButtonEngine(){}
    virtual void updateBadgeNumber(int num) = 0;
    virtual void updateProgress(qreal progress) = 0;
    virtual void updateLauncher(const QVariant &launcher) = 0;
};

#endif // ASEMANABSTRACTTASKBARBUTTONENGINE_H
