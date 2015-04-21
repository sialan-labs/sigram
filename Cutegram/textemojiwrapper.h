#ifndef TEXTEMOJIWRAPPER_H
#define TEXTEMOJIWRAPPER_H

#include <QObject>
#include <QQuickTextDocument>

class Emojis;
class TextEmojiWrapperPrivate;
class TextEmojiWrapper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQuickTextDocument* textDocument READ textDocument WRITE setTextDocument NOTIFY textDocumentChanged)
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(Emojis* emojisItem READ emojisItem WRITE setEmojisItem NOTIFY emojisItemChanged)

public:
    TextEmojiWrapper(QObject *parent = 0);
    ~TextEmojiWrapper();

    void setTextDocument(QQuickTextDocument *doc);
    QQuickTextDocument *textDocument() const;

    void setEmojisItem(Emojis *emojisItem);
    Emojis *emojisItem() const;

    void setText(const QString &text);
    QString text() const;

public slots:
    void refresh();

signals:
    void textDocumentChanged();
    void textChanged();
    void emojisItemChanged();

private:
    TextEmojiWrapperPrivate *p;
};

#endif // TEXTEMOJIWRAPPER_H
