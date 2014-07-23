/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef TELEGRAMGUI_H
#define TELEGRAMGUI_H

#include <QObject>
#include <QSystemTrayIcon>
#include <QVariant>

class QQuickItem;
class QSettings;
class TelegramGuiPrivate;
class TelegramGui : public QObject
{
    Q_PROPERTY(int desktopSession READ desktopSession NOTIFY desktopSessionChanged)
    Q_PROPERTY(QString appPath READ appPath NOTIFY appPathChanged)
    Q_PROPERTY(QString background READ background WRITE setBackground NOTIFY backgroundChanged)
    Q_PROPERTY(bool firstTime READ firstTime WRITE setFirstTime NOTIFY firstTimeChanged)
    Q_PROPERTY(int width READ width WRITE setWidth NOTIFY widthChanged)
    Q_PROPERTY(int height READ height WRITE setHeight NOTIFY heightChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(QString country READ country WRITE setCountry NOTIFY countryChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(bool donate READ donate WRITE setDonate NOTIFY donateChanged)
    Q_PROPERTY(bool muteAll READ muteAll WRITE setMuteAll NOTIFY muteAllChanged)
    Q_PROPERTY(bool donateViewShowed READ donateViewShowed WRITE setDonateViewShowed NOTIFY donateViewShowedChanged)
    Q_PROPERTY(int love READ love WRITE setLove NOTIFY loveChanged)
    Q_OBJECT

public:
    TelegramGui(QObject *parent = 0);
    ~TelegramGui();

    static QSettings *settings();

    Q_INVOKABLE void setMute( int id, bool stt );
    Q_INVOKABLE bool isMuted( int id ) const;

    Q_INVOKABLE void setFavorite( int id, bool stt );
    Q_INVOKABLE bool isFavorited( int id ) const;

    Q_INVOKABLE QString aboutSialanStr() const;
    Q_INVOKABLE QString version() const;

    Q_INVOKABLE QSize screenSize() const;
    Q_INVOKABLE QPoint mousePos() const;

    Q_INVOKABLE QPoint mapToGlobal(QQuickItem *item, const QPoint &pnt );
    Q_INVOKABLE QPoint mapToScene(QQuickItem *item, const QPoint &pnt );

    Q_INVOKABLE QString appPath() const;
    Q_INVOKABLE QStringList fonts() const;
    Q_INVOKABLE QStringList fontsOf( const QString & path ) const;

    Q_INVOKABLE void setBackground( const QString & path );
    Q_INVOKABLE QString background() const;

    Q_INVOKABLE void setLove( int uid );
    Q_INVOKABLE int love() const;

    Q_INVOKABLE void setMuteAll( bool state );
    Q_INVOKABLE bool muteAll() const;

    Q_INVOKABLE void setFirstTime( bool stt );
    Q_INVOKABLE bool firstTime() const;

    Q_INVOKABLE QString getOpenFile();

    Q_INVOKABLE QSize imageSize( const QString & path );
    Q_INVOKABLE qreal htmlWidth( const QString & txt );

    Q_INVOKABLE QString license() const;

    Q_INVOKABLE QString fixPhoneNumber(QString number );

    static int desktopSession();

    void setWidth( int w );
    int width() const;

    void setHeight( int h );
    int height() const;

    void setVisible( bool v );
    bool visible() const;

    static void setCountry(const QString & country);
    static QString country();

    void setLanguage(const QString & ln);
    QString language() const;

    Q_INVOKABLE QStringList languages() const;

    static Qt::LayoutDirection directionOf( const QString & str );

    static void setDonate(bool stt);
    static bool donate();

    static void setDonateViewShowed(bool stt);
    static bool donateViewShowed();

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
    void showLicense();
    void showDonate();
    void quit();
    void show();

    void logout();

    void setSysTrayCounter( int count );
    void incomingAppMessage( const QString & msg );

    /*! This funtion made to better debuging qml problems !*/
    QVariant call( QObject *obj, const QString & member, const QVariant & v0 = QVariant(),
                                                         const QVariant & v1 = QVariant(),
                                                         const QVariant & v2 = QVariant(),
                                                         const QVariant & v3 = QVariant(),
                                                         const QVariant & v4 = QVariant(),
                                                         const QVariant & v5 = QVariant(),
                                                         const QVariant & v6 = QVariant(),
                                                         const QVariant & v7 = QVariant(),
                                                         const QVariant & v8 = QVariant(),
                                                         const QVariant & v9 = QVariant() );

signals:
    void muted( int id, bool stt );
    void favorited( int id, bool stt );
    void desktopSessionChanged();
    void appPathChanged();
    void backgroundChanged();
    void firstTimeChanged();
    void heightChanged();
    void widthChanged();
    void visibleChanged();
    void countryChanged();
    void donateChanged();
    void languageChanged();
    void donateViewShowedChanged();
    void muteAllChanged();
    void loveChanged();

private slots:
    void notify_action( uint id, const QString & act );
    void systray_action( QSystemTrayIcon::ActivationReason act );

private:
    QImage generateIcon( const QImage & img, int count );

    void showContextMenu();
    void init_languages();
    void check_files();

private:
    TelegramGuiPrivate *p;
};

#endif // TELEGRAMGUI_H
