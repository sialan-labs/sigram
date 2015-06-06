#ifndef ASEMANTASKBARBUTTON_H
#define ASEMANTASKBARBUTTON_H

#include <QObject>
#include <QVariant>

class QWindow;
class AsemanTaskbarButtonPrivate;
class AsemanTaskbarButton : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int      badgeNumber READ badgeNumber WRITE setBadgeNumber NOTIFY badgeNumberChanged)
    Q_PROPERTY(qreal    progress    READ progress    WRITE setProgress    NOTIFY progressChanged   )
    Q_PROPERTY(QString  launcher    READ launcher    WRITE setLauncher    NOTIFY launcherChanged   )
    Q_PROPERTY(QWindow* window      READ window      WRITE setWindow      NOTIFY windowChanged     )

public:
    AsemanTaskbarButton(QObject *parent = 0);
    ~AsemanTaskbarButton();

    void setBadgeNumber(int num);
    int badgeNumber() const;

    void setProgress(qreal progress);
    qreal progress() const;

    void setLauncher(const QString &launcher);
    QString launcher() const;

    void setWindow(QWindow *win);
    QWindow *window() const;

public slots:
    void userAttention();

signals:
    void badgeNumberChanged();
    void progressChanged();
    void launcherChanged();
    void windowChanged();

private:
    AsemanTaskbarButtonPrivate *p;
};

#endif // ASEMANTASKBARBUTTON_H
