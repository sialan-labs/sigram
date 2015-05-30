#include "asemanwintaskbarbuttonengine.h"

#include <QWindow>
#include <QImage>
#include <QIcon>
#include <QPainter>
#include <QPainterPath>
#include <QRect>
#include <QDebug>

#ifdef QT_WINEXTRAS_LIB
#include <QtWin>
#include <QWinTaskbarButton>
#include <QWinTaskbarProgress>
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

void AsemanWinTaskbarButtonEngine::updateWindow(QWindow *window)
{
    if(_button->window() == window)
        return;
    if(_button->window()) {
        updateBadgeNumber(0);
        updateProgress(0);
    }

    _button->setWindow(window);
}

QImage AsemanWinTaskbarButtonEngine::generateIcon(int count)
{
    QImage res = QImage(22, 22, QImage::Format_ARGB32);
    res.fill(QColor(0,0,0,0));

    if( count == 0 )
        return res;

    QRect rct;
    rct.setX(1);
    rct.setY(1);
    rct.setWidth(res.width() - 2*rct.x());
    rct.setHeight(res.height() - 2*rct.y());

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

