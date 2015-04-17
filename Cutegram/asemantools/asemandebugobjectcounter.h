#ifndef ASEMANDEBUGOBJECTCOUNTER_H
#define ASEMANDEBUGOBJECTCOUNTER_H

#include <QObject>

class AsemanDebugObjectCounterPrivate;
class AsemanDebugObjectCounter : public QObject
{
    Q_OBJECT
public:
    AsemanDebugObjectCounter(QObject *parent = 0);
    ~AsemanDebugObjectCounter();

public slots:
    void start(QObject *object, int interval);

private slots:
    void timeout();

private:
    void calculate(QObject *obj, QMap<QString, int> &count);

private:
    AsemanDebugObjectCounterPrivate *p;
};

#endif // ASEMANDEBUGOBJECTCOUNTER_H
