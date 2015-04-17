#ifndef MP3CONVERTERENGINE_H
#define MP3CONVERTERENGINE_H

#include <QObject>

class MP3ConverterEnginePrivate;
class MP3ConverterEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString destination READ destination WRITE setDestination NOTIFY destinationChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)

public:
    MP3ConverterEngine(QObject *parent = 0);
    ~MP3ConverterEngine();

    void setSource(const QString &source);
    QString source() const;

    void setDestination(const QString &destination);
    QString destination() const;

    bool running() const;

public slots:
    void start();

signals:
    void sourceChanged();
    void destinationChanged();
    void finished();
    void error();
    void runningChanged();

private slots:
    void finished_prv();

private:
    MP3ConverterEnginePrivate *p;
};

#endif // MP3CONVERTERENGINE_H
