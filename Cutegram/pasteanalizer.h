#ifndef PASTEANALIZER_H
#define PASTEANALIZER_H

#include <QObject>
#include <QUrl>

class PasteAnalizerPrivate;
class PasteAnalizer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text NOTIFY textChanged)
    Q_PROPERTY(QString path READ path NOTIFY pathChanged)
    Q_PROPERTY(QString temp READ temp WRITE setTemp NOTIFY tempChanged)

public:
    PasteAnalizer(QObject *parent = 0);
    ~PasteAnalizer();

    QString path() const;
    QString text() const;

    QString temp() const;
    void setTemp(const QString &temp);

public slots:
    bool analize();

signals:
    void pathChanged();
    void textChanged();
    void tempChanged();

private:
    PasteAnalizerPrivate *p;
};

#endif // PASTEANALIZER_H
