#ifndef ASEMANABSTRACTTASKBARBUTTONENGINE_H
#define ASEMANABSTRACTTASKBARBUTTONENGINE_H

#include <QtGlobal>
#include <QVariant>

class QWindow;
class AsemanAbstractTaskbarButtonEngine
{
public:
    virtual ~AsemanAbstractTaskbarButtonEngine(){}
    virtual void updateBadgeNumber(int num) = 0;
    virtual void updateProgress(qreal progress) = 0;
    virtual void updateLauncher(const QString &launcher) {Q_UNUSED(launcher)}
    virtual void updateWindow(QWindow *window) {Q_UNUSED(window)}
    virtual void userAttention() {}
};

#endif // ASEMANABSTRACTTASKBARBUTTONENGINE_H
