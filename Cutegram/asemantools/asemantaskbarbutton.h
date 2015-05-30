#ifndef ASEMANTASKBARBUTTON_H
#define ASEMANTASKBARBUTTON_H

#include <QObject>
#include <QVariant>

class AsemanTaskbarButtonPrivate;
class AsemanTaskbarButton : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int      badgeNumber READ badgeNumber WRITE setBadgeNumber NOTIFY badgeNumberChanged)
    Q_PROPERTY(qreal    progress    READ progress    WRITE setProgress    NOTIFY progressChanged   )
    Q_PROPERTY(QVariant launcher    READ launcher    WRITE setLauncher    NOTIFY launcherChanged   )

public:
    AsemanTaskbarButton(QObject *parent = 0);
    ~AsemanTaskbarButton();

    void setBadgeNumber(int num);
    int badgeNumber() const;

    void setProgress(qreal progress);
    qreal progress() const;

    void setLauncher(const QVariant &launcher);
    QVariant launcher() const;

signals:
    void badgeNumberChanged();
    void progressChanged();
    void launcherChanged();

private:
    AsemanTaskbarButtonPrivate *p;
};

#endif // ASEMANTASKBARBUTTON_H
