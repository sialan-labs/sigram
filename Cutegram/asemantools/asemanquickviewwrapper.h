#ifndef ASEMANQUICKVIEWWRAPPER_H
#define ASEMANQUICKVIEWWRAPPER_H

#include <QObject>
#include "asemanquickview.h"

class AsemanQuickViewWrapper : public QObject
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
    Q_PROPERTY(QWindow* window READ window NOTIFY fakeSignal)

public:
    AsemanQuickViewWrapper(AsemanQuickView *view, QObject *parent = 0);
    ~AsemanQuickViewWrapper();

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

    QWindow *window() const;

public slots:
    void discardFocusedText();
    void tryClose();

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

private slots:
    void viewDestroyed();

private:
    AsemanQuickView *mView;
};

#endif // ASEMANQUICKVIEWWRAPPER_H
