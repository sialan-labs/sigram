/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef CUTEGRAM_H
#define CUTEGRAM_H

#include <QObject>
#include <QSize>
#include <QVariantMap>
#include <QSystemTrayIcon>
#include <QFont>

class DatabaseAbstractEncryptor;
class QMenu;
class ThemeItem;
class CutegramPrivate;
class Cutegram : public QObject
{
    Q_OBJECT
    Q_ENUMS(StartupOptions)
    Q_ENUMS(StatusIconStyles)

    Q_PROPERTY(QString defaultHostAddress READ defaultHostAddress WRITE setDefaultHostAddress NOTIFY defaultHostAddressChanged)
    Q_PROPERTY(int defaultHostPort READ defaultHostPort WRITE setDefaultHostPort NOTIFY defaultHostPortChanged)
    Q_PROPERTY(int defaultHostDcId READ defaultHostDcId WRITE setDefaultHostDcId NOTIFY defaultHostDcIdChanged)
    Q_PROPERTY(int appId READ appId WRITE setAppId NOTIFY appIdChanged)
    Q_PROPERTY(QString appHash READ appHash WRITE setAppHash NOTIFY appHashChanged)

    Q_PROPERTY(DatabaseAbstractEncryptor* encrypter READ encrypter NOTIFY encrypterChanged)

    Q_PROPERTY(QStringList languages READ languages NOTIFY fakeSignal)
    Q_PROPERTY(QString personalStickerDirectory READ personalStickerDirectory NOTIFY fakeSignal)
    Q_PROPERTY(QColor highlightColor READ highlightColor WRITE setHighlightColor NOTIFY highlightColorChanged)

    Q_PROPERTY(QString language     READ language     WRITE setLanguage     NOTIFY languageChanged    )
    Q_PROPERTY(QString messageAudio READ messageAudio WRITE setMessageAudio NOTIFY messageAudioChanged)
    Q_PROPERTY(QString background   READ background   WRITE setBackground   NOTIFY backgroundChanged  )
    Q_PROPERTY(QFont   font         READ font         WRITE setFont         NOTIFY fontChanged        )
    Q_PROPERTY(QString masterColor  READ masterColor  WRITE setMasterColor  NOTIFY masterColorChanged )

    Q_PROPERTY(int  sysTrayCounter    READ sysTrayCounter    WRITE setSysTrayCounter  NOTIFY sysTrayCounterChanged   )
    Q_PROPERTY(int  startupOption     READ startupOption     WRITE setStartupOption   NOTIFY startupOptionChanged    )
    Q_PROPERTY(bool notification      READ notification      WRITE setNotification    NOTIFY notificationChanged     )
    Q_PROPERTY(bool emojiOnHover      READ emojiOnHover      WRITE setEmojiOnHover    NOTIFY emojiOnHoverChanged     )
    Q_PROPERTY(bool minimumDialogs    READ minimumDialogs    WRITE setMinimumDialogs  NOTIFY minimumDialogsChanged   )
    Q_PROPERTY(bool showLastMessage   READ showLastMessage   WRITE setShowLastMessage NOTIFY showLastMessageChanged  )
    Q_PROPERTY(bool darkSystemTray    READ darkSystemTray    WRITE setDarkSystemTray  NOTIFY darkSystemTrayChanged   )
    Q_PROPERTY(bool cutegramSubscribe READ cutegramSubscribe WRITE setAsemanSubscribe NOTIFY cutegramSubscribeChanged)
    Q_PROPERTY(int  statusIconStyle   READ statusIconStyle   WRITE setStatusIconStyle NOTIFY statusIconStyleChanged  )
    Q_PROPERTY(bool smoothScroll      READ smoothScroll      WRITE setSmoothScroll    NOTIFY smoothScrollChanged     )
    Q_PROPERTY(bool autoEmojis        READ autoEmojis        WRITE setAutoEmojis      NOTIFY autoEmojisChanged       )
    Q_PROPERTY(bool sendByCtrlEnter   READ sendByCtrlEnter   WRITE setSendByCtrlEnter NOTIFY sendByCtrlEnterChanged  )
    Q_PROPERTY(bool kWallet           READ kWallet           WRITE setKWallet         NOTIFY kWalletChanged          )

    Q_PROPERTY(ThemeItem* currentTheme READ currentTheme NOTIFY currentThemeChanged)
    Q_PROPERTY(QStringList themes READ themes NOTIFY themesChanged)
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(QStringList emojisThemes READ emojisThemes NOTIFY emojisThemesChanged)
    Q_PROPERTY(QString emojisTheme READ emojisTheme WRITE setEmojisTheme NOTIFY emojisThemeChanged)

    Q_PROPERTY(QStringList searchEngines READ searchEngines NOTIFY searchEnginesChanged)
    Q_PROPERTY(QString searchEngine READ searchEngine WRITE setSearchEngine NOTIFY searchEngineChanged)

    Q_PROPERTY(bool closingState READ closingState NOTIFY closingStateChanged)

public:
    enum StartupOptions {
        StartupAutomatic = 0,
        StartupVisible = 1,
        StartupHide = 2
    };

    enum StatusIconStyles {
        StatusIconAutomatic,
        StatusIconDark,
        StatusIconLight
    };

    Cutegram(QObject *parent = 0);
    ~Cutegram();

    Q_INVOKABLE static QVariantList intListToVariantList(const QList<qint32> &list);
    Q_INVOKABLE static QList<qint32> variantListToIntList(const QVariantList &list);

    Q_INVOKABLE QSize imageSize( const QString & path );
    Q_INVOKABLE bool filsIsImage(const QString & path);
    Q_INVOKABLE qreal htmlWidth( const QString & txt );

    Q_INVOKABLE void deleteFile(const QString &path);
    Q_INVOKABLE QString storeMessage(const QString &msg);

    Q_INVOKABLE QString getTimeString( const QDateTime & dt );

    Q_INVOKABLE int showMenu( const QStringList & actions, QPoint point = QPoint() );

    void setDefaultHostAddress(const QString &host);
    QString defaultHostAddress() const;

    void setDefaultHostPort(int port);
    int defaultHostPort() const;

    void setDefaultHostDcId(int dcId);
    int defaultHostDcId() const;

    void setAppId(int appId);
    int appId() const;

    void setAppHash(const QString &appHash);
    QString appHash() const;

    void setSysTrayCounter(int count , bool force = false);
    int sysTrayCounter() const;

    QStringList languages();

    void setLanguage( const QString & lang );
    QString language() const;

    bool closingState() const;

    void setStartupOption( int opt );
    int startupOption() const;

    void setNotification(bool stt);
    bool notification() const;

    void setEmojiOnHover(bool stt);
    bool emojiOnHover() const;

    void setMinimumDialogs(bool stt);
    bool minimumDialogs() const;

    void setShowLastMessage(bool stt);
    bool showLastMessage() const;

    void setDarkSystemTray(bool stt);
    bool darkSystemTray() const;

    void setSmoothScroll(bool stt);
    bool smoothScroll() const;

    void setKWallet(bool stt);
    bool kWallet() const;

    void setBackground(const QString &background);
    QString background() const;

    void setMessageAudio(const QString &file);
    QString messageAudio() const;

    void setMasterColor(const QString &color);
    QString masterColor() const;

    QColor highlightColor() const;
    void setHighlightColor(const QColor &color);

    void setVisualEffects(bool stt);
    bool visualEffects() const;

    void setFont(const QFont &font);
    QFont font() const;

    void setAsemanSubscribe(bool stt);
    bool cutegramSubscribe() const;

    void setAutoEmojis(bool stt);
    bool autoEmojis() const;

    void setSendByCtrlEnter(bool stt);
    bool sendByCtrlEnter() const;

    void setStatusIconStyle(int style);
    int statusIconStyle();

    QStringList themes() const;
    void setTheme(const QString &theme);
    QString theme() const;
    ThemeItem *currentTheme();

    QStringList emojisThemes() const;
    void setEmojisTheme(const QString& theme);
    QString emojisTheme() const;

    QStringList searchEngines() const;
    void setSearchEngine(const QString &se);
    QString searchEngine() const;

    QString personalStickerDirectory() const;

    DatabaseAbstractEncryptor *encrypter();
    void setEncrypterKey(const QString &key);

    Q_INVOKABLE bool isLoggedIn(const QString &phone) const;
    Q_INVOKABLE QString normalizeText(const QString &text) const;

public slots:
    void start(bool forceVisible = false);
    void restart();
    void logout(const QString & phone);
    void close();
    void quit();
    void contact();
    void aboutAseman();
    void about();
    void configure();
    void incomingAppMessage(const QString & msg);
    void active();
    void addToPersonal(const QString &src);
    void installSticker(const QString &shortName);

signals:
    void defaultHostAddressChanged();
    void defaultHostPortChanged();
    void defaultHostDcIdChanged();
    void appIdChanged();
    void appHashChanged();
    void encrypterChanged();

    void backRequest();
    void sysTrayCounterChanged();
    void fakeSignal();
    void emojiOnHoverChanged();
    void languageChanged();
    void languageDirectionChanged();
    void startupOptionChanged();
    void notificationChanged();
    void minimumDialogsChanged();
    void showLastMessageChanged();
    void backgroundChanged();
    void messageAudioChanged();
    void masterColorChanged();
    void highlightColorChanged();
    void darkSystemTrayChanged();
    void fontChanged();
    void closingStateChanged();
    void cutegramSubscribeChanged();
    void statusIconStyleChanged();
    void smoothScrollChanged();
    void autoEmojisChanged();
    void sendByCtrlEnterChanged();
    void kWalletChanged();

    void themesChanged();
    void currentThemeChanged();
    void themeChanged();

    void emojisThemesChanged();
    void emojisThemeChanged();

    void searchEngineChanged();
    void searchEnginesChanged();

    void configureRequest();
    void aboutAsemanRequest();

protected:
    bool eventFilter(QObject *o, QEvent *e);

private slots:
    void systray_action( QSystemTrayIcon::ActivationReason act );

private:
    void init_systray();
    QImage generateIcon( const QImage & img, int count );
    void init_languages();
    void init_theme();

    bool lowLevelDarkSystemTray();

    QMenu *contextMenu();

private:
    CutegramPrivate *p;
};

Q_DECLARE_METATYPE( QList<qint32> )

#endif // CUTEGRAM_H
