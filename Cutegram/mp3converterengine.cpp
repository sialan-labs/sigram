#include "mp3converterengine.h"

#include <QProcess>
#include <QFileInfo>
#include <QCoreApplication>
#include <QPointer>

class MP3ConverterEnginePrivate
{
public:
    QPointer<QProcess> process;
    QString source;
    QString destination;
};

MP3ConverterEngine::MP3ConverterEngine(QObject *parent) :
    QObject(parent)
{
    p = new MP3ConverterEnginePrivate;
    p->process = 0;
}

void MP3ConverterEngine::setSource(const QString &source)
{
    if(p->source == source)
        return;

    p->source = source;
    emit sourceChanged();
}

QString MP3ConverterEngine::source() const
{
    return p->source;
}

void MP3ConverterEngine::setDestination(const QString &destination)
{
    if(p->destination == destination)
        return;

    p->destination = destination;
    emit destinationChanged();
}

QString MP3ConverterEngine::destination() const
{
    return p->destination;
}

bool MP3ConverterEngine::running() const
{
    return p->process;
}

void MP3ConverterEngine::start()
{
    if(p->process)
        return;

    QStringList args;
    args << "-i";
    args << p->source;
    args << "-acodec";
    args << "libmp3lame";
    args << "-ac";
    args << "2";
    args << "-ab";
    args << "64k";
    args << "-ar";
    args << "44100";
    args << p->destination;

    QString ffmpegPath;
#ifdef Q_OS_WIN
    ffmpegPath = QCoreApplication::applicationDirPath() + "/ffmpeg.exe";
#else
#ifdef Q_OS_MAC
    ffmpegPath = QCoreApplication::applicationDirPath() + "/ffmpeg";
#else
    if(QFileInfo::exists("/usr/bin/avconv"))
        ffmpegPath = "/usr/bin/avconv";
    else
        ffmpegPath = "ffmpeg";
#endif
#endif

    p->process = new QProcess(this);

    connect(p->process, SIGNAL(error(QProcess::ProcessError)), SIGNAL(error()));
    connect(p->process, SIGNAL(finished(int)), SLOT(finished_prv()));

    p->process->start(ffmpegPath, args);
    emit runningChanged();
}

void MP3ConverterEngine::finished_prv()
{
    p->process->deleteLater();
    p->process = 0;

    emit finished();
    emit runningChanged();
}

MP3ConverterEngine::~MP3ConverterEngine()
{
    delete p;
}

