#ifndef TELEGRAMGUI_H
#define TELEGRAMGUI_H

#include <QObject>
#include <QSystemTrayIcon>

class TelegramGuiPrivate;
class TelegramGui : public QObject
{
    Q_OBJECT
public:
    TelegramGui(QObject *parent = 0);
    ~TelegramGui();

    Q_INVOKABLE void setMute( int id, bool stt );
    Q_INVOKABLE bool muted( int id ) const;

public slots:
    void start();
    void sendNotify(quint64 msg_id);

private slots:
    void notify_action( uint id, const QString & act );
    void systray_action( QSystemTrayIcon::ActivationReason act );

private:
    void showContextMenu();

private:
    TelegramGuiPrivate *p;
};

#endif // TELEGRAMGUI_H
