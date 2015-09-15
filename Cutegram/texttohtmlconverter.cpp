#include "texttohtmlconverter.h"
#include "asemantools/asemanfonthandler.h"
#include "emojis.h"

#include <QPointer>

class TextToHtmlConverterPrivate
{
public:
    QPointer<Emojis> emojis;
    QPointer<AsemanFontHandler> fontHandler;
    QString text;
    QString html;
};

TextToHtmlConverter::TextToHtmlConverter(QObject *parent) :
    QObject(parent)
{
    p = new TextToHtmlConverterPrivate;
}

void TextToHtmlConverter::setEmojisItem(Emojis *emojis)
{
    if(p->emojis == emojis)
        return;

    p->emojis = emojis;

    refresh();
    emit emojisItemChanged();
}

Emojis *TextToHtmlConverter::emojisItem() const
{
    return p->emojis;
}

void TextToHtmlConverter::setFontHandler(AsemanFontHandler *handler)
{
    if(p->fontHandler == handler)
        return;
    if(p->fontHandler)
        disconnect(p->fontHandler, SIGNAL(fontsChanged()), this, SLOT(refresh()));

    p->fontHandler = handler;
    if(p->fontHandler)
        connect(p->fontHandler, SIGNAL(fontsChanged()), this, SLOT(refresh()));

    refresh();
    emit fontHandlerChanged();
}

AsemanFontHandler *TextToHtmlConverter::fontHandler() const
{
    return p->fontHandler;
}

void TextToHtmlConverter::setText(const QString &text)
{
    if(p->text == text)
        return;

    p->text = text;

    refresh();
    emit textChanged();
}

QString TextToHtmlConverter::text() const
{
    return p->text;
}

QString TextToHtmlConverter::html() const
{
    return p->html;
}

void TextToHtmlConverter::refresh()
{
    QString result = p->text;
    if(p->emojis)
        result = p->emojis->bodyTextToEmojiText(result);
    if(p->fontHandler)
        result = p->fontHandler->textToHtml(result);

    p->html = result;
    emit htmlChanged();
}

TextToHtmlConverter::~TextToHtmlConverter()
{
    delete p;
}

