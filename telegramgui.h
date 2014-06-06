#ifndef TELEGRAMGUI_H
#define TELEGRAMGUI_H

#include <QObject>
#include <QSystemTrayIcon>

class QQuickItem;
class QSettings;
class TelegramGuiPrivate;
class TelegramGui : public QObject
{
    Q_PROPERTY(int desktopSession READ desktopSession NOTIFY desktopSessionChanged)
    Q_PROPERTY(QString appPath READ appPath NOTIFY appPathChanged)
    Q_PROPERTY(QString background READ background WRITE setBackground NOTIFY backgroundChanged)
    Q_PROPERTY(bool firstTime READ firstTime WRITE setFirstTime NOTIFY firstTimeChanged)
    Q_OBJECT
public:
    TelegramGui(QObject *parent = 0);
    ~TelegramGui();

    static QSettings *settings();

    Q_INVOKABLE void setMute( int id, bool stt );
    Q_INVOKABLE bool isMuted( int id ) const;

    Q_INVOKABLE QSize screenSize() const;
    Q_INVOKABLE QPoint mousePos() const;

    Q_INVOKABLE QPoint mapToGlobal(QQuickItem *item, const QPoint &pnt );
    Q_INVOKABLE QPoint mapToScene(QQuickItem *item, const QPoint &pnt );

    Q_INVOKABLE QString appPath() const;
    Q_INVOKABLE QStringList fonts() const;
    Q_INVOKABLE QStringList fontsOf( const QString & path ) const;

    Q_INVOKABLE void setBackground( const QString & path );
    Q_INVOKABLE QString background() const;

    Q_INVOKABLE void setFirstTime( bool stt );
    Q_INVOKABLE bool firstTime() const;

    Q_INVOKABLE QString getOpenFile();

    Q_INVOKABLE QSize imageSize( const QString & path );
    Q_INVOKABLE qreal htmlWidth( const QString & txt );

    static int desktopSession();

public slots:
    void start();
    void sendNotify(quint64 msg_id);

    void openFile( const QString & file );
    void openUrl( const QUrl & url );
    void copyFile( const QString & file );
    void saveFile( const QString & file );

    void copyText( const QString & txt );

    int showMenu( const QStringList & list );

    void configure();
    void about();
    void aboutSialan();
    void quit();
    void show();

signals:
    void muted( int id, bool stt );
    void desktopSessionChanged();
    void appPathChanged();
    void backgroundChanged();
    void firstTimeChanged();

private slots:
    void notify_action( uint id, const QString & act );
    void systray_action( QSystemTrayIcon::ActivationReason act );

private:
    void showContextMenu();

private:
    TelegramGuiPrivate *p;
};

#endif // TELEGRAMGUI_H
