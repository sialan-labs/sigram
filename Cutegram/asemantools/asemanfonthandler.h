#ifndef ASEMANFONTHANDLER_H
#define ASEMANFONTHANDLER_H

#include <QObject>
#include <QHash>
#include <QVariant>
#include <QFont>
#include <QMap>

class AsemanFontHandlerPrivate;
class AsemanFontHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap fonts READ fonts WRITE setFonts NOTIFY fontsChanged)

public:
    AsemanFontHandler(QObject *parent = 0);
    ~AsemanFontHandler();

    QVariantMap fonts();
    void setFonts(const QVariantMap &fonts);

    Q_INVOKABLE QFont fontOf(int script);
    Q_INVOKABLE QString textToHtml(const QString &text);

    Q_INVOKABLE QByteArray save();
    Q_INVOKABLE void load(const QByteArray &data);

public slots:
#ifdef QT_WIDGETS_LIB
    void openFontChooser();
#endif

signals:
    void fontsChanged();

private slots:
    void init();
#ifdef QT_WIDGETS_LIB
    void currentIndexChanged(const QString &key);
    void currentFontChanged(const QFont &font);
#endif

private:
    AsemanFontHandlerPrivate *p;
};

#endif // ASEMANFONTHANDLER_H
