#include "asemanfonthandler.h"
#include "asemanlistrecord.h"

#include <QFont>
#include <QHash>
#include <QDebug>

#ifdef QT_WIDGETS_LIB
#include <QDialog>
#include <QFontDialog>
#include <QComboBox>
#include <QVBoxLayout>
#endif

QMap<int,QString> aseman_font_handler_scipts;

class AsemanFontHandlerPrivate
{
public:
    QVariantMap fonts;
#ifdef QT_WIDGETS_LIB
    QHash<QComboBox*, QFontDialog*> combo_hash;
    QHash<QComboBox*, QVariantMap> combo_cache;
#endif
};

AsemanFontHandler::AsemanFontHandler(QObject *parent) :
    QObject(parent)
{
    p = new AsemanFontHandlerPrivate;

    if(aseman_font_handler_scipts.isEmpty())
    {
        aseman_font_handler_scipts[QChar::Script_Unknown] = "unknown";
        aseman_font_handler_scipts[QChar::Script_Inherited] = "inherited";
        aseman_font_handler_scipts[QChar::Script_Common] = "common";
        aseman_font_handler_scipts[QChar::Script_Latin] = "latin";
        aseman_font_handler_scipts[QChar::Script_Greek] = "greek";
        aseman_font_handler_scipts[QChar::Script_Cyrillic] = "cyrillic";
        aseman_font_handler_scipts[QChar::Script_Armenian] = "armenian";
        aseman_font_handler_scipts[QChar::Script_Hebrew] = "hebrew";
        aseman_font_handler_scipts[QChar::Script_Arabic] = "arabic";
        aseman_font_handler_scipts[QChar::Script_Syriac] = "syriac";
        aseman_font_handler_scipts[QChar::Script_Thaana] = "thaana";
        aseman_font_handler_scipts[QChar::Script_Devanagari] = "devanagari";
        aseman_font_handler_scipts[QChar::Script_Bengali] = "bengali";
        aseman_font_handler_scipts[QChar::Script_Gurmukhi] = "gurmukhi";
        aseman_font_handler_scipts[QChar::Script_Gujarati] = "gujarati";
        aseman_font_handler_scipts[QChar::Script_Oriya] = "oriya";
        aseman_font_handler_scipts[QChar::Script_Tamil] = "tamil";
        aseman_font_handler_scipts[QChar::Script_Telugu] = "telugu";
        aseman_font_handler_scipts[QChar::Script_Kannada] = "kannada";
        aseman_font_handler_scipts[QChar::Script_Malayalam] = "malayalam";
        aseman_font_handler_scipts[QChar::Script_Sinhala] = "sinhala";
        aseman_font_handler_scipts[QChar::Script_Thai] = "thai";
        aseman_font_handler_scipts[QChar::Script_Lao] = "lao";
        aseman_font_handler_scipts[QChar::Script_Tibetan] = "tibetan";
        aseman_font_handler_scipts[QChar::Script_Myanmar] = "myanmar";
        aseman_font_handler_scipts[QChar::Script_Georgian] = "georgian";
        aseman_font_handler_scipts[QChar::Script_Hangul] = "hangul";
        aseman_font_handler_scipts[QChar::Script_Ethiopic] = "ethiopic";
        aseman_font_handler_scipts[QChar::Script_Cherokee] = "cherokee";
        aseman_font_handler_scipts[QChar::Script_CanadianAboriginal] = "canadianAboriginal";
        aseman_font_handler_scipts[QChar::Script_Ogham] = "ogham";
        aseman_font_handler_scipts[QChar::Script_Runic] = "runic";
        aseman_font_handler_scipts[QChar::Script_Khmer] = "khmer";
        aseman_font_handler_scipts[QChar::Script_Mongolian] = "mongolian";
        aseman_font_handler_scipts[QChar::Script_Hiragana] = "hiragana";
        aseman_font_handler_scipts[QChar::Script_Katakana] = "katakana";
        aseman_font_handler_scipts[QChar::Script_Bopomofo] = "bopomofo";
        aseman_font_handler_scipts[QChar::Script_Han] = "han";
        aseman_font_handler_scipts[QChar::Script_Yi] = "yi";
        aseman_font_handler_scipts[QChar::Script_OldItalic] = "oldItalic";
        aseman_font_handler_scipts[QChar::Script_Gothic] = "gothic";
        aseman_font_handler_scipts[QChar::Script_Deseret] = "deseret";
        aseman_font_handler_scipts[QChar::Script_Tagalog] = "tagalog";
        aseman_font_handler_scipts[QChar::Script_Hanunoo] = "hanunoo";
        aseman_font_handler_scipts[QChar::Script_Buhid] = "buhid";
        aseman_font_handler_scipts[QChar::Script_Tagbanwa] = "tagbanwa";
        aseman_font_handler_scipts[QChar::Script_Coptic] = "coptic";
        aseman_font_handler_scipts[QChar::Script_Limbu] = "limbu";
        aseman_font_handler_scipts[QChar::Script_TaiLe] = "taiLe";
        aseman_font_handler_scipts[QChar::Script_LinearB] = "linearB";
        aseman_font_handler_scipts[QChar::Script_Ugaritic] = "ugaritic";
        aseman_font_handler_scipts[QChar::Script_Shavian] = "shavian";
        aseman_font_handler_scipts[QChar::Script_Osmanya] = "osmanya";
        aseman_font_handler_scipts[QChar::Script_Cypriot] = "cypriot";
        aseman_font_handler_scipts[QChar::Script_Braille] = "braille";
        aseman_font_handler_scipts[QChar::Script_Buginese] = "buginese";
        aseman_font_handler_scipts[QChar::Script_NewTaiLue] = "newTaiLue";
        aseman_font_handler_scipts[QChar::Script_Glagolitic] = "glagolitic";
        aseman_font_handler_scipts[QChar::Script_Tifinagh] = "tifinagh";
        aseman_font_handler_scipts[QChar::Script_SylotiNagri] = "sylotiNagri";
        aseman_font_handler_scipts[QChar::Script_OldPersian] = "oldPersian";
        aseman_font_handler_scipts[QChar::Script_Kharoshthi] = "kharoshthi";
        aseman_font_handler_scipts[QChar::Script_Balinese] = "balinese";
        aseman_font_handler_scipts[QChar::Script_Cuneiform] = "cuneiform";
        aseman_font_handler_scipts[QChar::Script_Phoenician] = "phoenician";
        aseman_font_handler_scipts[QChar::Script_PhagsPa] = "phagsPa";
        aseman_font_handler_scipts[QChar::Script_Nko] = "nko";
        aseman_font_handler_scipts[QChar::Script_Sundanese] = "sundanese";
        aseman_font_handler_scipts[QChar::Script_Lepcha] = "lepcha";
        aseman_font_handler_scipts[QChar::Script_OlChiki] = "olChiki";
        aseman_font_handler_scipts[QChar::Script_Vai] = "vai";
        aseman_font_handler_scipts[QChar::Script_Saurashtra] = "saurashtra";
        aseman_font_handler_scipts[QChar::Script_KayahLi] = "kayahLi";
        aseman_font_handler_scipts[QChar::Script_Rejang] = "rejang";
        aseman_font_handler_scipts[QChar::Script_Lycian] = "lycian";
        aseman_font_handler_scipts[QChar::Script_Carian] = "carian";
        aseman_font_handler_scipts[QChar::Script_Lydian] = "lydian";
        aseman_font_handler_scipts[QChar::Script_Cham] = "cham";
        aseman_font_handler_scipts[QChar::Script_TaiTham] = "taiTham";
        aseman_font_handler_scipts[QChar::Script_TaiViet] = "taiViet";
        aseman_font_handler_scipts[QChar::Script_Avestan] = "avestan";
        aseman_font_handler_scipts[QChar::Script_EgyptianHieroglyphs] = "egyptianHieroglyphs";
        aseman_font_handler_scipts[QChar::Script_Samaritan] = "samaritan";
        aseman_font_handler_scipts[QChar::Script_Lisu] = "lisu";
        aseman_font_handler_scipts[QChar::Script_Bamum] = "bamum";
        aseman_font_handler_scipts[QChar::Script_Javanese] = "javanese";
        aseman_font_handler_scipts[QChar::Script_MeeteiMayek] = "meeteiMayek";
        aseman_font_handler_scipts[QChar::Script_ImperialAramaic] = "imperialAramaic";
        aseman_font_handler_scipts[QChar::Script_OldSouthArabian] = "oldSouthArabian";
        aseman_font_handler_scipts[QChar::Script_InscriptionalParthian] = "inscriptionalParthian";
        aseman_font_handler_scipts[QChar::Script_InscriptionalPahlavi] = "inscriptionalPahlavi";
        aseman_font_handler_scipts[QChar::Script_OldTurkic] = "oldTurkic";
        aseman_font_handler_scipts[QChar::Script_Kaithi] = "kaithi";
        aseman_font_handler_scipts[QChar::Script_Batak] = "batak";
        aseman_font_handler_scipts[QChar::Script_Brahmi] = "brahmi";
        aseman_font_handler_scipts[QChar::Script_Mandaic] = "mandaic";
        aseman_font_handler_scipts[QChar::Script_Chakma] = "chakma";
        aseman_font_handler_scipts[QChar::Script_MeroiticCursive] = "meroiticCursive";
        aseman_font_handler_scipts[QChar::Script_MeroiticHieroglyphs] = "meroiticHieroglyphs";
        aseman_font_handler_scipts[QChar::Script_Miao] = "miao";
        aseman_font_handler_scipts[QChar::Script_Sharada] = "sharada";
        aseman_font_handler_scipts[QChar::Script_SoraSompeng] = "soraSompeng";
        aseman_font_handler_scipts[QChar::Script_Takri] = "takri";
    }

    init();
}

QVariantMap AsemanFontHandler::fonts()
{
    return p->fonts;
}

void AsemanFontHandler::setFonts(const QVariantMap &fonts)
{
    if(p->fonts == fonts)
        return;

    p->fonts = fonts;
    emit fontsChanged();
}

QFont AsemanFontHandler::fontOf(int script)
{
    const QString &key = aseman_font_handler_scipts.value(static_cast<QChar::Script>(script));
    return p->fonts.value(key).value<QFont>();
}

QString AsemanFontHandler::textToHtml(const QString &text)
{
    QString result;
    QChar::Script lastScript = QChar::Script_Unknown;

    int level = 0;
    for(int i=0; i<text.length(); i++)
    {
        const QChar &ch = text.at(i);
        if(ch == '<')
            level++;
        if(level > 0)
        {
            if(ch == '>')
                level--;

            result += ch;
            continue;
        }

        QChar::Script script = (ch=='&'? QChar::Script_Latin : ch.script());
        if(script <= QChar::Script_Common && lastScript != QChar::Script_Unknown)
            script = lastScript;

        if(lastScript != script)
        {
            if(lastScript != QChar::Script_Unknown)
                result += "</span>";

            QString scriptKey = aseman_font_handler_scipts.value(script);
            QFont font = p->fonts.value(scriptKey).value<QFont>();

            result += QString("<span style=\"font-family:'%1'; font-size:%2pt; font-style:%3;\">")
                    .arg(font.family()).arg(font.pointSize()).arg(font.styleName());
        }

        result += ch;
        lastScript = script;
    }

    return result;
}

QByteArray AsemanFontHandler::save()
{
    AsemanListRecord list;
    QMapIterator<QString, QVariant> i(p->fonts);
    while(i.hasNext())
    {
        i.next();
        AsemanListRecord record;
        record << i.key().toUtf8();
        record << i.value().toString().toUtf8();

        list << record.toQByteArray();
    }

    return list.toQByteArray();
}

void AsemanFontHandler::load(const QByteArray &data)
{
    AsemanListRecord list(data);
    for(int i=0; i<list.count(); i++)
    {
        AsemanListRecord record(list.at(i));
        if(record.count() != 2)
            continue;

        QFont font;
        font.fromString(record.last());
        p->fonts[record.first()] = font;
    }

    emit fontsChanged();
}

#ifdef QT_WIDGETS_LIB
void AsemanFontHandler::openFontChooser()
{
    QDialog dialog;
    dialog.resize(QSize(500, 400));

    QComboBox *comboBox = new QComboBox();
    comboBox->addItems(p->fonts.keys());

    QFontDialog *fontDlg = new QFontDialog();
    fontDlg->setWindowFlags(Qt::Widget);
    fontDlg->setWindowTitle(tr("Select font"));

    p->combo_hash[comboBox] = fontDlg;
    p->combo_cache[comboBox] = p->fonts;

    QVBoxLayout *layout = new QVBoxLayout(&dialog);
    layout->addWidget(comboBox);
    layout->addWidget(fontDlg);
    layout->setContentsMargins(0,0,0,0);
    layout->setSpacing(1);

    connect(comboBox, SIGNAL(currentIndexChanged(QString)), SLOT(currentIndexChanged(QString)));
    connect(fontDlg , SIGNAL(currentFontChanged(QFont))   , SLOT(currentFontChanged(QFont))   );

    connect(fontDlg, SIGNAL(accepted()), &dialog, SLOT(accept()));
    connect(fontDlg, SIGNAL(rejected()), &dialog, SLOT(reject()));

    comboBox->setCurrentText("latin");
    comboBox->currentIndexChanged("latin");

    if(dialog.exec() == QDialog::Accepted)
        p->fonts = p->combo_cache[comboBox];

    p->combo_hash.remove(comboBox);
    p->combo_cache.remove(comboBox);

    emit fontsChanged();
}

void AsemanFontHandler::currentIndexChanged(const QString &key)
{
    QComboBox *comboBox = static_cast<QComboBox*>(sender());
    QFontDialog *fontDlg = p->combo_hash.value(comboBox);
    QFont font = p->combo_cache[comboBox][key].value<QFont>();
    fontDlg->setCurrentFont(font);
}

void AsemanFontHandler::currentFontChanged(const QFont &font)
{
    QFontDialog *fontDlg = static_cast<QFontDialog*>(sender());
    QComboBox *comboBox = p->combo_hash.key(fontDlg);
    QString key = comboBox->currentText();
    p->combo_cache[comboBox][key] = font;
}
#endif

void AsemanFontHandler::init()
{
    p->fonts.clear();
    QFont defaultFont;
    QMapIterator<int, QString> i(aseman_font_handler_scipts);
    while(i.hasNext())
    {
        i.next();
        p->fonts[i.value()] = defaultFont;
    }
}

AsemanFontHandler::~AsemanFontHandler()
{
    delete p;
}

