#ifndef VERSIONCHECKER_H
#define VERSIONCHECKER_H

#include <QObject>

class VersionCheckerPrivate;
class VersionChecker : public QObject
{
    Q_OBJECT
public:
    VersionChecker(QObject *parent = 0);
    ~VersionChecker();

signals:
    void updateAvailable( qreal version, const QString & info );

public slots:
    void check();
    void dismiss( qreal version );

private slots:
    void checked(const QByteArray & data);

protected:
    void timerEvent(QTimerEvent *e);

private:
    VersionCheckerPrivate *p;
};

#endif // VERSIONCHECKER_H
