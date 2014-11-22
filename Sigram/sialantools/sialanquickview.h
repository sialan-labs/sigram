/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

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

#ifndef SIALANQUICKVIEW_H
#define SIALANQUICKVIEW_H

#include <QQuickView>

class SialanBackHandler;
class SialanDesktopTools;
class SialanDevices;
class SialanJavaLayer;
class SialanQtLogger;
class SialanTools;
class SialanCalendarConverter;
class SialanQuickViewPrivate;
class SialanQuickView : public QQuickView
{
    Q_OBJECT

    Q_PROPERTY(bool fullscreen READ fullscreen WRITE setFullscreen NOTIFY fullscreenChanged)

    Q_PROPERTY(qreal statusBarHeight READ statusBarHeight NOTIFY statusBarHeightChanged)
    Q_PROPERTY(qreal navigationBarHeight READ navigationBarHeight NOTIFY navigationBarHeightChanged)

    Q_PROPERTY(QQuickItem* root        READ root        WRITE setRoot        NOTIFY rootChanged)
    Q_PROPERTY(QQuickItem* focusedText READ focusedText WRITE setFocusedText NOTIFY focusedTextChanged)

    Q_PROPERTY(int layoutDirection READ layoutDirection WRITE setLayoutDirection NOTIFY layoutDirectionChanged)

public:
    enum OptionsFlag {
        None = 0,
        DesktopTools = 1,
        Devices = 2,
        JavaLayer = 4,
        QtLogger = 8,
        Tools = 16,
        Calendar = 32,
        BackHandler = 64,
        AllComponents = 127,
        AllExceptLogger = 119
    };

    SialanQuickView( int options = Devices|BackHandler, QWindow *parent = 0);
    ~SialanQuickView();

    SialanDesktopTools *desktopTools() const;
    SialanDevices *devices() const;
    SialanQtLogger *qtLogger() const;
    SialanTools *tools() const;
#ifdef Q_OS_ANDROID
    SialanJavaLayer *javaLayer() const;
#endif
    SialanCalendarConverter *calendar() const;
    SialanBackHandler *backHandler() const;

    void setFullscreen( bool stt );
    bool fullscreen() const;

    qreal statusBarHeight() const;
    qreal navigationBarHeight() const;

    void setRoot( QQuickItem *root );
    QQuickItem *root() const;

    void setFocusedText( QQuickItem *item );
    QQuickItem *focusedText() const;

    int layoutDirection() const;
    void setLayoutDirection( int l );

public slots:
    void discardFocusedText();

signals:
    void fullscreenChanged();
    void statusBarHeightChanged();
    void navigationBarHeightChanged();
    void rootChanged();
    void focusedTextChanged();
    void layoutDirectionChanged();
    void fakeSignal();

private slots:
    void init_options();

private:
    SialanQuickViewPrivate *p;
};

#endif // SIALANQUICKVIEW_H
