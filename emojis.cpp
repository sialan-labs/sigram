#include "emojis.h"
#include "telegram_macros.h"

#include <QHash>
#include <QFile>
#include <QDebug>
#include <QTextDocument>

class EmojisPrivate
{
public:
    QHash<QString,QString> emojis;
    QString theme;

    QTextDocument *doc;
};

Emojis::Emojis(QObject *parent) :
    QObject(parent)
{
    p = new EmojisPrivate;
    p->doc = new QTextDocument(this);

    setCurrentTheme("apple");
}

void Emojis::setCurrentTheme(const QString &theme)
{
    QString path = EMOJIS_PATH + theme + "/";
    QString conf = path + "theme";

    QFile cfile(conf);
    if( !cfile.open(QFile::ReadOnly) )
        return;

    p->theme = theme;
    p->emojis.clear();

    const QString data = cfile.readAll();
    const QStringList & list = data.split("\n",QString::SkipEmptyParts);
    foreach( const QString & l, list )
    {
        const QStringList & parts = l.split("\t",QString::SkipEmptyParts);
        if( parts.count() < 2 )
            continue;

        p->emojis[parts.at(1)] = path + parts.at(0);
    }

    emit currentThemeChanged();
}

QString Emojis::currentTheme() const
{
    return p->theme;
}

QString Emojis::textToEmojiText(const QString &txt)
{
    p->doc->setHtml(txt);
    QString res = p->doc->toPlainText();
    for( int i=0; i<res.size(); i++ )
    {
        for( int j=1; j<5; j++ )
        {
            QString emoji = res.mid(i,j);
            if( !p->emojis.contains(emoji) )
                continue;

            QString path = p->emojis.value(emoji);
            QString in_txt = QString("<img align=\"top\" height=\"18\" width=\"18\" src=\"file://%1\" />").arg(path);
            res.replace(i,j,in_txt);
            i += in_txt.size()-1;
            break;
        }
    }

    if( res.contains("<img") )
        res = "<font size=\"1\">.</font>" + res;

    return res;
}

Emojis::~Emojis()
{
    delete p;
}
