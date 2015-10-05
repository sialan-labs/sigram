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

#ifndef ASEMANQUICKVIEW_H
#define ASEMANQUICKVIEW_H

#include <QQuickView>
#include <QQmlEngine>

#ifdef ASEMAN_QML_PLUGIN
#define INHERIT_VIEW QObject
#else
#define INHERIT_VIEW QQuickView
#endif

class AsemanBackHandler;
class AsemanDesktopTools;
class AsemanDevices;
class AsemanJavaLayer;
class AsemanQtLogger;
class AsemanTools;
class AsemanCalendarConverter;
class AsemanQuickViewPrivate;
class AsemanQuickView : public INHERIT_VIEW
{
    Q_OBJECT

    Q_PROPERTY(bool fullscreen READ fullscreen WRITE setFullscreen NOTIFY fullscreenChanged)
    Q_PROPERTY(bool backController READ backController WRITE setBackController NOTIFY backControllerChanged)
    Q_PROPERTY(bool reverseScroll READ reverseScroll WRITE setReverseScroll NOTIFY reverseScrollChanged)

    Q_PROPERTY(qreal statusBarHeight READ statusBarHeight NOTIFY statusBarHeightChanged)
    Q_PROPERTY(qreal navigationBarHeight READ navigationBarHeight NOTIFY navigationBarHeightChanged)

    Q_PROPERTY(QObject*    root        READ root        WRITE setRoot        NOTIFY rootChanged)
    Q_PROPERTY(QQuickItem* focusedText READ focusedText WRITE setFocusedText NOTIFY focusedTextChanged)

    Q_PROPERTY(int layoutDirection READ layoutDirection WRITE setLayoutDirection NOTIFY layoutDirectionChanged)

    Q_PROPERTY(qreal flickVelocity READ flickVelocity NOTIFY fakeSignal)

public:

#ifdef ASEMAN_QML_PLUGIN
    AsemanQuickView(QQmlEngine *engine, QObject *parent = 0);
#else
    AsemanQuickView(QWindow *parent = 0);
#endif
    ~AsemanQuickView();

    AsemanDesktopTools *desktopTools() const;
    AsemanDevices *devices() const;
    AsemanQtLogger *qtLogger() const;
    AsemanTools *tools() const;
#ifdef Q_OS_ANDROID
    AsemanJavaLayer *javaLayer() const;
#endif
    AsemanCalendarConverter *calendar() const;
    AsemanBackHandler *backHandler() const;

    void setFullscreen( bool stt );
    bool fullscreen() const;

    void setBackController(bool stt);
    bool backController() const;

    void setReverseScroll(bool stt);
    bool reverseScroll() const;

    qreal statusBarHeight() const;
    qreal navigationBarHeight() const;

    void setRoot( QObject *root );
    QObject *root() const;

    void setFocusedText( QQuickItem *item );
    QQuickItem *focusedText() const;

    int layoutDirection() const;
    void setLayoutDirection( int l );

    qreal flickVelocity() const;
    Q_INVOKABLE QSize screenSize() const;

public slots:
    void discardFocusedText();
    void tryClose();
    void setMask(qreal x, qreal y, qreal width, qreal height);
    void move(qreal x, qreal y);
    void resize(qreal w, qreal h);

signals:
    void fullscreenChanged();
    void statusBarHeightChanged();
    void navigationBarHeightChanged();
    void rootChanged();
    void focusedTextChanged();
    void layoutDirectionChanged();
    void backControllerChanged();
    void reverseScrollChanged();
    void fakeSignal();
    void closeRequest();

protected:
    bool event(QEvent *e);

private:
    AsemanQuickViewPrivate *p;
};

#endif // ASEMANQUICKVIEW_H
