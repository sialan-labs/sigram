#ifndef TELEGRAMGUI_H
#define TELEGRAMGUI_H

#include <QObject>
#include <QSystemTrayIcon>

class QSettings;
class TelegramGuiPrivate;
class TelegramGui : public QObject
{
    Q_PROPERTY(int desktopSession READ desktopSession NOTIFY desktopSessionChanged)
    Q_OBJECT
public:
    TelegramGui(QObject *parent = 0);
    ~TelegramGui();

    static QSettings *settings();

    Q_INVOKABLE void setMute( int id, bool stt );
    Q_INVOKABLE bool isMuted( int id ) const;

    static int desktopSession();

public slots:
    void start();
    void sendNotify(quint64 msg_id);

signals:
    void muted( int id, bool stt );
    void desktopSessionChanged();

private slots:
    void notify_action( uint id, const QString & act );
    void systray_action( QSystemTrayIcon::ActivationReason act );

private:
    void showContextMenu();

private:
    TelegramGuiPrivate *p;
};

#endif // TELEGRAMGUI_H
