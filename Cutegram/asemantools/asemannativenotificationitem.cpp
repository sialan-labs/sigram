#define ROUNDED_PIXEL    5
#define SHADOW_COLOR     palette().highlight().color()
#define SHADOW_SIZE      20

#include "asemannativenotificationitem.h"

#include <QPainterPath>
#include <QPaintEvent>
#include <QSize>
#include <QPainter>
#include <QGraphicsBlurEffect>
#include <QLabel>
#include <QPushButton>
#include <QToolButton>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QDesktopWidget>
#include <QApplication>
#include <QTimer>
#include <QPixmap>

class DialogBack: public QWidget
{
public:
    DialogBack( QWidget *parent = 0 ): QWidget(parent){
        effect = new QGraphicsBlurEffect(this);
        effect->setBlurRadius(SHADOW_SIZE-10);
        setGraphicsEffect(effect);
        color = QColor(0,0,0,255);
    }

    void setColor( const QColor & color ){
        DialogBack::color = color;
        repaint();
    }

    ~DialogBack(){}

protected:
    void paintEvent(QPaintEvent *e){
        QPainter painter(this);
        painter.setRenderHint( QPainter::Antialiasing , true );
        painter.fillRect( e->rect(), color );
    }

private:
    QGraphicsBlurEffect *effect;
    QColor color;
};

class DialogScene: public QWidget
{
public:
    DialogScene( QWidget *parent = 0 ): QWidget(parent){    }
    ~DialogScene(){}

    QPainterPath dialogPath( const QRect & rct , int padding ) const
    {
        QPainterPath path;
        path.setFillRule( Qt::WindingFill );

        path.moveTo( rct.width()/2 , padding );
        path.lineTo( rct.width()-padding-ROUNDED_PIXEL , padding );
        path.quadTo( rct.width()-padding , padding , rct.width()-padding , padding+ROUNDED_PIXEL );
        path.lineTo( rct.width()-padding , rct.height()-padding-ROUNDED_PIXEL );
        path.quadTo( rct.width()-padding , rct.height()-padding , rct.width()-padding-ROUNDED_PIXEL , rct.height()-padding );
        path.lineTo( padding+ROUNDED_PIXEL , rct.height()-padding );
        path.quadTo( padding , rct.height()-padding , padding , rct.height()-padding-ROUNDED_PIXEL );
        path.lineTo( padding , padding+ROUNDED_PIXEL );
        path.quadTo( padding , padding , padding+ROUNDED_PIXEL , padding );
        path.lineTo( rct.width()/2 , padding );

        return path;
    }

protected:
    void paintEvent(QPaintEvent *e){
        Q_UNUSED(e)
        QPainter painter(this);
        painter.setRenderHint( QPainter::Antialiasing , true );
        painter.fillPath( dialogPath(rect(),0), QColor(255,255,255) );
    }
};

class AsemanNativeNotificationItemPrivate
{
public:
    DialogBack *back;
    DialogScene *scene;

    QColor shadow_color;

    QVBoxLayout *layout;
    QHBoxLayout *body_layout;
    QVBoxLayout *btns_layout;
    QHBoxLayout *ttle_layout;

    QLabel *title_lbl;
    QLabel *body_lbl;
    QLabel *icon_lbl;

    QList<QPushButton*> buttons;
    QHash<QPushButton*,QString> actions;

    QToolButton *close_btn;
};


AsemanNativeNotificationItem::AsemanNativeNotificationItem(QWidget *parent) :
    QWidget(parent)
{
    p = new AsemanNativeNotificationItemPrivate;
    p->shadow_color = QColor( SHADOW_COLOR );

    p->back = new DialogBack(this);
    p->back->setColor( p->shadow_color );

    p->scene = new DialogScene( this );

    p->title_lbl = new QLabel();
    p->title_lbl->setAlignment(Qt::AlignCenter);
    p->title_lbl->setFixedHeight(26);

    p->close_btn = new QToolButton();
    p->close_btn->setText("X");
    p->close_btn->setFixedSize(26, 26);
    p->close_btn->setAutoRaise(true);

    p->ttle_layout = new QHBoxLayout();
    p->ttle_layout->addWidget(p->title_lbl);
    p->ttle_layout->addWidget(p->close_btn);
    p->ttle_layout->setContentsMargins(0,0,0,0);
    p->ttle_layout->setSpacing(1);

    p->icon_lbl = new QLabel();
    p->icon_lbl->setFixedSize(64, 64);
    p->icon_lbl->setScaledContents(true);

    p->body_lbl = new QLabel();
    p->body_lbl->setWordWrap(true);

    p->btns_layout = new QVBoxLayout();
    p->btns_layout->setContentsMargins(0,0,0,0);
    p->btns_layout->setSpacing(1);

    p->body_layout = new QHBoxLayout();
    p->body_layout->addWidget(p->icon_lbl);
    p->body_layout->addWidget(p->body_lbl, 10000);
    p->body_layout->addLayout(p->btns_layout);
    p->body_layout->setContentsMargins(0,0,0,0);
    p->body_layout->setSpacing(8);

    p->layout = new QVBoxLayout(this);
    p->layout->addLayout(p->ttle_layout);
    p->layout->addLayout(p->body_layout);
    p->layout->setContentsMargins(SHADOW_SIZE+10,SHADOW_SIZE+8,SHADOW_SIZE+10,SHADOW_SIZE+8);
    p->layout->setSpacing(1);

    setWindowFlags( Qt::Window | Qt::FramelessWindowHint );
    setAttribute(Qt::WA_TranslucentBackground);
    setAttribute(Qt::WA_NoSystemBackground);
    setAttribute(Qt::WA_DeleteOnClose);
    setMouseTracking( true );
    setWindowOpacity(0.9);

    refreshSize();

    connect(p->close_btn, SIGNAL(clicked()), SLOT(close()) );
}

void AsemanNativeNotificationItem::setActions(const QStringList &actions)
{
    for(int i=0; i<p->btns_layout->count(); i++)
        delete p->btns_layout->takeAt(i);

    for(int i=1 ;i<actions.count(); i+=2)
    {
        const QString &action = actions.at(i-1);
        const QString &text = actions.at(i);

        QPushButton *btn = new QPushButton();
        btn->setText(text);

        p->actions.insert(btn, action);
        p->buttons << btn;

        p->btns_layout->addWidget(btn);

        connect(btn, SIGNAL(clicked()), SLOT(buttonClicked()) );
    }

    p->body_layout->addStretch();
}

void AsemanNativeNotificationItem::setTitle(const QString &title)
{
    p->title_lbl->setText(title);
}

void AsemanNativeNotificationItem::setBody(const QString &body)
{
    p->body_lbl->setText(body.left(100) + "...");
}

void AsemanNativeNotificationItem::setIcon(const QString &icon)
{
    p->icon_lbl->setPixmap( QPixmap(icon) );
}

void AsemanNativeNotificationItem::setTimeOut(int timeOut)
{
    if(timeOut == 0)
        return;

    QTimer::singleShot(timeOut, this, SLOT(close()) );
}

void AsemanNativeNotificationItem::resizeEvent(QResizeEvent *e)
{
    refreshSize();
    QWidget::resizeEvent(e);
}

void AsemanNativeNotificationItem::mouseReleaseEvent(QMouseEvent *e)
{
    Q_UNUSED(e)
    close();
}

void AsemanNativeNotificationItem::refreshSize()
{
    QRect rect( SHADOW_SIZE, SHADOW_SIZE, width()-2*SHADOW_SIZE, height()-2*SHADOW_SIZE );

    const QRect &scr = QApplication::desktop()->availableGeometry();

    p->back->setGeometry( rect );
    p->scene->setGeometry( rect );

    move(scr.x()+scr.width()-width()+SHADOW_SIZE*0.7, scr.y()+scr.height()-height()+SHADOW_SIZE*0.7);
}

void AsemanNativeNotificationItem::setRaised()
{
    raise();
}

void AsemanNativeNotificationItem::buttonClicked()
{
    QPushButton *btn = static_cast<QPushButton*>(sender());
    if(!btn)
        return;

    const QString &action = p->actions.value(btn);
    emit actionTriggered(action);
}

AsemanNativeNotificationItem::~AsemanNativeNotificationItem()
{
    delete p;
}

