#include "asemanwintaskbarbuttonengine.h"

#include <QWindow>
#include <QImage>
#include <QIcon>
#include <QPainter>
#include <QPainterPath>
#include <QRect>

#ifdef QT_WINEXTRAS_LIB
#include <QtWin>
#include <QWinTaskbarButton>
#include <QWinTaskbarProgress>
#else
typedef QObject QWinTaskbarButton;
#endif

AsemanWinTaskbarButtonEngine::AsemanWinTaskbarButtonEngine()
{
    _button = new QWinTaskbarButton();
}

void AsemanWinTaskbarButtonEngine::updateBadgeNumber(int number)
{
    if(!_button->window())
        return;

    _button->setOverlayIcon( QIcon(QPixmap::fromImage(generateIcon(number))) );
}

void AsemanWinTaskbarButtonEngine::updateProgress(qreal progress)
{
    if(!_button->window())
        return;

    _button->progress()->setVisible(progress != 0);
    _button->progress()->setValue(progress);
}

void AsemanWinTaskbarButtonEngine::updateLauncher(const QVariant &launcher)
{
    QWindow *newWin = launcher.value<QWindow*>();
    if(_button->window() == newWin)
        return;

    if(_button->window()) {
        updateBadgeNumber(0);
        updateProgress(0);
    }

    _button->setWindow(newWin);
}

QImage AsemanWinTaskbarButtonEngine::generateIcon(int count)
{
    QImage res = QImage(64, 64);
    res.fill(QColor(0,0,0,0));

    if( count == 0 )
        return res;

    QRect rct = res.rect();

    QPainterPath path;
    path.addEllipse(rct);

    QPainter painter(&res);
    painter.setRenderHint( QPainter::Antialiasing , true );
    painter.fillPath( path, QColor("#ff0000") );
    painter.setPen("#333333");
    painter.drawPath( path );
    painter.setPen("#ffffff");
    painter.drawText( rct, Qt::AlignCenter | Qt::AlignHCenter, QString::number(count) );

    return res;
}

AsemanWinTaskbarButtonEngine::~AsemanWinTaskbarButtonEngine()
{
    delete _button;
}

