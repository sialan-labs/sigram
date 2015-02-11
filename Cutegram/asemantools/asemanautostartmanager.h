#ifndef ASEMANAUTOSTARTMANAGER_H
#define ASEMANAUTOSTARTMANAGER_H

#include <QObject>
#include <QUrl>

class AsemanAutoStartManagerPrivate;
class AsemanAutoStartManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString command READ command WRITE setCommand NOTIFY commandChanged)
    Q_PROPERTY(QString comment READ comment WRITE setComment NOTIFY commentChanged)
    Q_PROPERTY(QString source  READ source  WRITE setSource  NOTIFY sourceChanged )
    Q_PROPERTY(QString name    READ name    WRITE setName    NOTIFY nameChanged   )
    Q_PROPERTY(QString type    READ type    WRITE setType    NOTIFY typeChanged   )
    Q_PROPERTY(bool    active  READ active  WRITE setActive  NOTIFY activeChanged )

public:
    AsemanAutoStartManager(QObject *parent = 0);
    ~AsemanAutoStartManager();

    void setCommand(const QString &cmd);
    QString command() const;

    void setSource(const QString &fileName);
    QString source() const;

    void setComment(const QString &txt);
    QString comment() const;

    void setName(const QString &name);
    QString name() const;

    void setType(const QString &t);
    QString type() const;

    void setActive(bool active);
    bool active() const;

public slots:
    void refresh();
    void save();

signals:
    void commandChanged();
    void sourceChanged();
    void commentChanged();
    void nameChanged();
    void typeChanged();
    void activeChanged();

private:
    AsemanAutoStartManagerPrivate *p;
};

#endif // ASEMANAUTOSTARTMANAGER_H
