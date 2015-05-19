#define ROUNDED_PIXEL    5
#define SHADOW_COLOR     palette().highlight().color()

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
#include <QStyleFactory>
#include <QDebug>

class DialogScene: public QWidget
{
public:
    DialogScene( QWidget *parent = 0 ): QWidget(parent){    }
    ~DialogScene(){}

protected:
    void paintEvent(QPaintEvent *e){
        Q_UNUSED(e)
        QPainter painter(this);
        painter.setRenderHint( QPainter::Antialiasing , true );
        painter.fillRect(e->rect(), palette().window());
    }
};

class AsemanNativeNotificationItemPrivate
{
public:
    DialogScene *scene;

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

    QColor color;
    QColor backColor;
    QColor textColor;
    QColor buttonColor;
};


AsemanNativeNotificationItem::AsemanNativeNotificationItem(QWidget *parent) :
    QWidget(parent)
{
    p = new AsemanNativeNotificationItemPrivate;

    QFont font;
    font.setPointSize(10);

    setFont(font);
    setColor(palette().highlight().color());

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
    p->layout->setContentsMargins(10,8,10,8);
    p->layout->setSpacing(1);

    setWindowFlags( Qt::ToolTip );
    setAttribute(Qt::WA_TranslucentBackground);
    setAttribute(Qt::WA_NoSystemBackground);
    setAttribute(Qt::WA_DeleteOnClose);
    setMouseTracking( true );
    setWindowOpacity(0.98);

    refreshSize();

    connect(p->close_btn, SIGNAL(clicked()), SLOT(close()) );
}

void AsemanNativeNotificationItem::setColor(const QColor &color)
{
    if(p->color == color)
        return;

    p->color = color;


    p->backColor = QColor( p->color.red()*0.8, p->color.green()*0.8, p->color.blue()*0.8 );
    p->buttonColor = QColor( p->color.red()*0.5, p->color.green()*0.5, p->color.blue()*0.5 );

    qreal mid = (p->buttonColor.red()+p->buttonColor.green()+p->buttonColor.blue())/3.0;
    p->textColor = mid>=128? QColor("#333333") : QColor("#ffffff");

    QPalette palette;
    palette.setColor(QPalette::Window, p->backColor);
    palette.setColor(QPalette::WindowText, p->textColor);
    palette.setColor(QPalette::ButtonText, "#ffffff");
    palette.setColor(QPalette::Button, p->buttonColor);
    setPalette(palette);

    emit colorChanged();
}

QColor AsemanNativeNotificationItem::color() const
{
    return p->color;
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
        btn->setPalette(QPalette());
        btn->setFont(QFont());

        static QStyle *style = QStyleFactory::create("Fusion");
        btn->setStyle(style);

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
    QRect rect( 0, 0, width(), height() );

    const QRect &scr = QApplication::desktop()->availableGeometry();

    p->scene->setGeometry( rect );

    move(scr.x()+scr.width()-width() - 4, scr.y()+scr.height()-height() - 4);
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

