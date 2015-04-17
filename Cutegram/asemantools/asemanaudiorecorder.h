#ifndef ASEMANAUDIORECORDER_H
#define ASEMANAUDIORECORDER_H

#include <QObject>
#include <QUrl>
#include <QMediaRecorder>
#include <QStringList>

class AsemanAudioEncoderSettings;
class AsemanAudioRecorderPrivate;
class AsemanAudioRecorder : public QObject
{
    Q_OBJECT
    Q_ENUMS(State)
    Q_ENUMS(Status)

    Q_PROPERTY(AsemanAudioEncoderSettings* encoderSettings READ encoderSettings WRITE setEncoderSettings NOTIFY encoderSettingsChanged)
    Q_PROPERTY(QUrl output READ output WRITE setOutput NOTIFY outputChanged)
    Q_PROPERTY(bool mute READ mute WRITE setMute NOTIFY muteChanged)
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(int availability READ availability NOTIFY availabilityChanged)
    Q_PROPERTY(int state READ state NOTIFY stateChanged)
    Q_PROPERTY(int status READ status NOTIFY statusChanged)
    Q_PROPERTY(qreal volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(QString audioInput READ audioInput WRITE setAudioInput NOTIFY audioInputChanged)
    Q_PROPERTY(QStringList audioInputs READ audioInputs NOTIFY audioInputsChanged)

public:
    enum State
    {
        StoppedState = QMediaRecorder::StoppedState,
        RecordingState = QMediaRecorder::RecordingState,
        PausedState = QMediaRecorder::PausedState
    };

    enum Status {
        UnavailableStatus = QMediaRecorder::UnavailableStatus,
        UnloadedStatus = QMediaRecorder::UnloadedStatus,
        LoadingStatus = QMediaRecorder::LoadingStatus,
        LoadedStatus = QMediaRecorder::LoadedStatus,
        StartingStatus = QMediaRecorder::StartingStatus,
        RecordingStatus = QMediaRecorder::RecordingStatus,
        PausedStatus = QMediaRecorder::PausedStatus,
        FinalizingStatus = QMediaRecorder::FinalizingStatus
    };

    AsemanAudioRecorder(QObject *parent = 0);
    ~AsemanAudioRecorder();

    AsemanAudioEncoderSettings *encoderSettings() const;
    void setEncoderSettings(AsemanAudioEncoderSettings *settings);

    void setOutput(const QUrl &url);
    QUrl output() const;

    bool mute() const;
    void setMute(bool stt);

    qreal volume() const;
    void setVolume(qreal vol);

    void setAudioInput(const QString &input);
    QString audioInput() const;
    QStringList audioInputs() const;

    bool available() const;
    int availability() const;
    int state() const;
    int status() const;

public slots:
    void stop();
    void pause();
    void record();

signals:
    void encoderSettingsChanged();
    void outputChanged();
    void muteChanged();
    void volumeChanged();
    void availableChanged();
    void availabilityChanged();
    void stateChanged();
    void statusChanged();
    void audioInputChanged();
    void audioInputsChanged();

private:
    AsemanAudioRecorderPrivate *p;
};

#endif // ASEMANAUDIORECORDER_H
