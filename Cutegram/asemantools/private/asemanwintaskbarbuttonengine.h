#ifndef ASEMANWINTASKBARBUTTONENGINE_H
#define ASEMANWINTASKBARBUTTONENGINE_H

#include "asemanabstracttaskbarbuttonengine.h"

class AsemanWinTaskbarButtonEngine : public AsemanAbstractTaskbarButtonEngine
{
public:
    AsemanWinTaskbarButtonEngine();
    ~AsemanWinTaskbarButtonEngine();

    void updateBadgeNumber(int number);
    void updateProgress(qreal progress);
    void updateLauncher(const QVariant &launcher);

private:
    QImage generateIcon(int count);

private:
    class QWinTaskbarButton *_button;
};

#endif // ASEMANWINTASKBARBUTTONENGINE_H
