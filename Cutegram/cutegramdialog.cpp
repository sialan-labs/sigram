#define UPDATE_DOWNLOAD_PATH "http://aseman.co/downloads/cutegram/newsletter/updates"
#define UPDATE_MESSAGE(MSG) QString("http://aseman.co/downloads/cutegram/newsletter/messages/%1").arg(MSG)

#define CUTEGRAM_DIALOG_ID INT_MAX-100

#include "cutegramdialog.h"
#include "telegramqml.h"
#include "userdata.h"
#include "types/types.h"
#include "asemantools/asemandownloader.h"

#include <QTimerEvent>
#include <QDomDocument>
#include <QLocale>
#include <QDateTime>
#include <QTimer>

class CutegramDialogPrivate
{
public:
    AsemanDownloader *checker;
    AsemanDownloader *downloader;
    int timer_id;

    TelegramQml *telegram;
    QDomDocument dom;

    QHash<int, MessageUpdate> msgTimers;
};

CutegramDialog::CutegramDialog(TelegramQml *parent) :
    QObject(parent)
{
    p = new CutegramDialogPrivate;
    p->telegram = parent;

    p->timer_id = startTimer(3600000);

    p->checker = new AsemanDownloader(this);
    p->checker->setPath(UPDATE_DOWNLOAD_PATH);

    p->downloader = new AsemanDownloader(this);

    connect(p->checker   , SIGNAL(finished(QByteArray)), SLOT(updateListReady(QByteArray)));
    connect(p->downloader, SIGNAL(finished(QByteArray)), SLOT(messageReceived(QByteArray)));

    qsrand(QDateTime::currentDateTime().toMSecsSinceEpoch());
    init_timers();

    QTimer::singleShot(1000, this, SLOT(check()));
}

Dialog CutegramDialog::dialog() const
{
    Peer peer(Peer::typePeerUser);
    peer.setUserId(CUTEGRAM_DIALOG_ID);

    Dialog dlg;
    dlg.setPeer(peer);

    return dlg;
}

User CutegramDialog::user() const
{
    User usr(User::typeUserContact);
    usr.setFirstName("Cutegram Newsletter");
    usr.setId(CUTEGRAM_DIALOG_ID);

    return usr;
}

void CutegramDialog::check()
{
    p->checker->start();
}

qint32 CutegramDialog::cutegramId()
{
    return CUTEGRAM_DIALOG_ID;
}

void CutegramDialog::updateListReady(const QByteArray &data)
{
    UserData *userData = p->telegram->userData();
    const quint64 lastMsgId = userData->value("last_update_msg_id").toULongLong();

    const QMap<quint64,QString> & umap = analizeUpdateList(data);
    if( umap.isEmpty() || umap.lastKey() <= lastMsgId )
        return;

    userData->setValue("last_update_msg_id", QString::number(umap.lastKey()));
    if(lastMsgId == 0)
        return;

    p->downloader->setPath( UPDATE_MESSAGE(umap.last()) );
    p->downloader->start();
}

void CutegramDialog::messageReceived(const QByteArray &data)
{
    QString errorStr;
    int errorLine;
    int errorColumn;

    UserData *userData = p->telegram->userData();
    if(!p->dom.setContent(data, true, &errorStr, &errorLine, &errorColumn))
        return;

    QDomElement root = p->dom.documentElement();
    if(root.tagName() != "CG")
        return;
    else
    if(root.hasAttribute("version") && root.attribute("version") < "1.0")
        return;

    QDomElement message = root.firstChildElement("message");
    if(message.isNull())
        return;

    QDomElement settings = message.firstChildElement("settings");

    const qint64 domain  = settings.attribute("domain").toULongLong();
    const QString & text = message.firstChildElement("text").text();
    const qint64 msgId   = message.attribute("msgId").toULongLong();

    if(domain != 0)
    {
        MessageUpdate update;
        update.id = msgId;
        update.date = QDateTime::currentDateTime().toMSecsSinceEpoch() + random()%domain;
        update.message = text;

        userData->addMessageUpdate(update);
        initTimer(msgId);
    }
    else
        initMessage(text, msgId);
}

QMap<quint64, QString> CutegramDialog::analizeUpdateList(const QByteArray &data)
{
    QMap<quint64, QString> result;
    if(data.trimmed().isEmpty())
        return result;

    const QString dataStr = data;
    const QStringList &lines = dataStr.split("\n", QString::SkipEmptyParts);
    foreach(const QString &l, lines)
    {
        const int idx = l.indexOf(",");
        if(idx <= 0)
            continue;

        const quint64 key = l.mid(0, idx).trimmed().toULongLong();
        const QString val = l.mid(idx+1).trimmed();
        if(key<=0 || val.isEmpty())
            continue;

        result[key] = val;
    }

    return result;
}

void CutegramDialog::initMessage(const QString &txt, qint32 msgId)
{
    Peer peer(Peer::typePeerUser);
    peer.setUserId(p->telegram->me());

    Message message;
    message.setId(msgId);
    message.setFromId(CUTEGRAM_DIALOG_ID);
    message.setToId(peer);
    message.setClassType(Message::typeMessage);
    message.setDate(QDateTime::currentDateTime().toTime_t());
    message.setOut(false);
    message.setUnread(false);
    message.setMessage(txt);

    Dialog dlg = dialog();
    dlg.setTopMessage(msgId);

    emit incomingMessage(message, dlg);
}

qint64 CutegramDialog::random() const
{
    quint64 res = 0;
    for(int i=0; i<10; i++)
        res += qrand();

    return res;
}

void CutegramDialog::init_timers()
{
    p->msgTimers.clear();

    UserData *userData = p->telegram->userData();
    const QList<quint64> msgIds = userData->messageUpdates();
    foreach(const quint64 msgId, msgIds)
        initTimer(msgId);
}

void CutegramDialog::initTimer(quint64 msgId)
{
    UserData *userData = p->telegram->userData();
    const MessageUpdate msgUpdate = userData->messageUpdateItem(msgId);
    qint64 interval = msgUpdate.date - QDateTime::currentDateTime().toMSecsSinceEpoch();
    if(interval <= 0)
    {
        initMessage(msgUpdate.message, msgUpdate.id);
        userData->removeMessageUpdate(msgUpdate.id);
        return;
    }

    int timerId = startTimer(interval);

    p->msgTimers[timerId] = msgUpdate;
}

void CutegramDialog::timerEvent(QTimerEvent *e)
{
    if(e->timerId() == p->timer_id)
        check();
    else
    if(p->msgTimers.contains(e->timerId()))
    {
        UserData *userData = p->telegram->userData();
        const MessageUpdate & msgUpdate = p->msgTimers.take(e->timerId());
        initMessage(msgUpdate.message, msgUpdate.id);
        userData->removeMessageUpdate(msgUpdate.id);
    }

    QObject::timerEvent(e);
}

CutegramDialog::~CutegramDialog()
{
    delete p;
}
