#include "textemojiwrapper.h"
#include "emojis.h"
#include "asemantools/asemandevices.h"

#include <QPointer>
#include <QTextDocument>
#include <QTextCursor>
#include <QDebug>

class TextEmojiWrapperPrivate
{
public:
    QPointer<QQuickTextDocument> document;
    QPointer<Emojis> emojis;
    QString text;
};

TextEmojiWrapper::TextEmojiWrapper(QObject *parent) :
    QObject(parent)
{
    p = new TextEmojiWrapperPrivate;
}

void TextEmojiWrapper::setTextDocument(QQuickTextDocument *doc)
{
    if(p->document == doc)
        return;

    p->document = doc;
    emit textDocumentChanged();

    refresh();
}

QQuickTextDocument *TextEmojiWrapper::textDocument() const
{
    return p->document;
}

void TextEmojiWrapper::setEmojisItem(Emojis *emojis)
{
    if(p->emojis == emojis)
        return;

    p->emojis = emojis;
    emit emojisItemChanged();

    refresh();
}

Emojis *TextEmojiWrapper::emojisItem() const
{
    return p->emojis;
}

void TextEmojiWrapper::setText(const QString &text)
{
    if(p->text == text)
        return;

    p->text = text;
    emit textChanged();

    refresh();
}

QString TextEmojiWrapper::text() const
{
    return p->text;
}

void TextEmojiWrapper::refresh()
{
    if(!p->document)
        return;
    if(!p->emojis)
        return;

    QTextDocument *document = p->document->textDocument();
    document->clear();

    QTextCursor cursor(document);
    cursor.setPosition(0);

    QString &text = p->text;
    const QHash<QString,QString> &emojis = p->emojis->emojis();
    for( int i=0; i<text.size(); i++ )
    {
        QString image;
        for( int j=1; j<5; j++ )
        {
            QString emoji = text.mid(i,j);
            if( !emojis.contains(emoji) )
                continue;

            image = emojis.value(emoji);
            i += emoji.size()-1;
            break;
        }

        if(image.isEmpty())
        {
            cursor.insertText(QString(text[i]));
        }
        else
        {
            QTextImageFormat format;
            format.setName(AsemanDevices::localFilesPrePath()+image);
            format.setHeight(18);
            format.setWidth(18);

            cursor.insertImage(format);
        }
    }
}

TextEmojiWrapper::~TextEmojiWrapper()
{
    delete p;
}

