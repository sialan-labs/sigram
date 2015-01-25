#ifndef CUTEGRAMDIALOG_H
#define CUTEGRAMDIALOG_H

#include <QObject>
#include <QMap>

class Dialog;
class User;
class Message;
class TelegramQml;
class CutegramDialogPrivate;
class CutegramDialog : public QObject
{
    Q_OBJECT
public:
    CutegramDialog(TelegramQml *parent);
    ~CutegramDialog();

    Dialog dialog() const;
    User user() const;

public slots:
    void check();
    static qint32 cutegramId();

signals:
    void incomingMessage(const Message &msg, const Dialog &dialog);

private slots:
    void updateListReady( const QByteArray & data );
    void messageReceived( const QByteArray & data );

private:
    QMap<quint64,QString> analizeUpdateList(const QByteArray &data);
    void initMessage(const QString &txt, qint32 msgId);
    qint64 random() const;

    void init_timers();
    void initTimer(quint64 msgId);

protected:
    void timerEvent(QTimerEvent *e);

private:
    CutegramDialogPrivate *p;
};

#endif // CUTEGRAMDIALOG_H
