#ifndef TELEGRAMGUI_H
#define TELEGRAMGUI_H

#include <QObject>

class TelegramGuiPrivate;
class TelegramGui : public QObject
{
    Q_OBJECT
public:
    TelegramGui(QObject *parent = 0);
    ~TelegramGui();

public slots:
    void start();

private:
    TelegramGuiPrivate *p;
};

#endif // TELEGRAMGUI_H
