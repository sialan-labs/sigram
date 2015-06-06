#ifndef BACKGROUNDMANAGER_H
#define BACKGROUNDMANAGER_H

#include <QObject>
#include <QUrl>

class DialogObject;
class BackgroundManagerPrivate;
class BackgroundManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl directory READ directory WRITE setDirectory NOTIFY directoryChanged)
    Q_PROPERTY(DialogObject* dialog READ dialog WRITE setDialog NOTIFY dialogChanged)
    Q_PROPERTY(QUrl background READ background NOTIFY backgroundChanged)

public:
    BackgroundManager(QObject *parent = 0);
    ~BackgroundManager();

    void setDirectory(const QUrl &path);
    QUrl directory() const;

    void setDialog(DialogObject *dialog);
    DialogObject *dialog() const;

    QUrl background() const;
    qint64 dialogId();

public slots:
    void setBackground(const QString &filePath);

signals:
    void directoryChanged();
    void dialogChanged();
    void backgroundChanged();

private:
    void refresh();

private:
    BackgroundManagerPrivate *p;
};

#endif // BACKGROUNDMANAGER_H
