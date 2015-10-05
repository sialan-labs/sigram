#ifndef TEXTTOHTMLCONVERTER_H
#define TEXTTOHTMLCONVERTER_H

#include <QObject>

class AsemanFontHandler;
class Emojis;
class TextToHtmlConverterPrivate;
class TextToHtmlConverter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(Emojis* emojisItem READ emojisItem WRITE setEmojisItem NOTIFY emojisItemChanged)
    Q_PROPERTY(AsemanFontHandler* fontHandler READ fontHandler WRITE setFontHandler NOTIFY fontHandlerChanged)
    Q_PROPERTY(QString html READ html NOTIFY htmlChanged)

public:
    TextToHtmlConverter(QObject *parent = 0);
    ~TextToHtmlConverter();

    void setEmojisItem(Emojis *emojisItem);
    Emojis *emojisItem() const;

    void setFontHandler(AsemanFontHandler *handler);
    AsemanFontHandler *fontHandler() const;

    void setText(const QString &text);
    QString text() const;

    QString html() const;

public slots:
    void refresh();

signals:
    void emojisItemChanged();
    void textChanged();
    void scriptKeysChanged();
    void fontHandlerChanged();
    void htmlChanged();

private:
    TextToHtmlConverterPrivate *p;
};

#endif // TEXTTOHTMLCONVERTER_H
