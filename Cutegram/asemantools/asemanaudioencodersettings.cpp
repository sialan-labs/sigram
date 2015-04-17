#include "asemanaudioencodersettings.h"

#include <QAudioEncoderSettings>

class AsemanAudioEncoderSettingsPrivate
{
public:
    QAudioEncoderSettings settings;
};

AsemanAudioEncoderSettings::AsemanAudioEncoderSettings(QObject *parent) :
    QObject(parent)
{
    p = new AsemanAudioEncoderSettingsPrivate;
}

int AsemanAudioEncoderSettings::bitRate() const
{
    return p->settings.bitRate();
}

void AsemanAudioEncoderSettings::setBitRate(int rate)
{
    if(p->settings.bitRate() == rate)
        return;

    p->settings.setBitRate(rate);
    emit bitRateChanged();
}

int AsemanAudioEncoderSettings::channelCount() const
{
    return p->settings.channelCount();
}

void AsemanAudioEncoderSettings::setChannelCount(int channels)
{
    if(p->settings.channelCount() == channels)
        return;

    p->settings.setChannelCount(channels);
    emit channelCountChanged();
}

QString AsemanAudioEncoderSettings::codec() const
{
    return p->settings.codec();
}

void AsemanAudioEncoderSettings::setCodec(const QString &cdc)
{
    if(p->settings.codec() == cdc)
        return;

    p->settings.setCodec(cdc);
    emit codecChanged();
}

int AsemanAudioEncoderSettings::encodingMode() const
{
    return p->settings.encodingMode();
}

void AsemanAudioEncoderSettings::setEncodingMode(int mode)
{
    if(p->settings.encodingMode() == mode)
        return;

    p->settings.setEncodingMode(static_cast<QMultimedia::EncodingMode>(mode));
    emit encodingModeChanged();
}

QVariantMap AsemanAudioEncoderSettings::encodingOptions() const
{
    return p->settings.encodingOptions();
}

void AsemanAudioEncoderSettings::setEncodingOptions(const QVariantMap &options)
{
    if(p->settings.encodingOptions() == options)
        return;

    p->settings.setEncodingOptions(options);
    emit encodingOptionsChanged();
}

int AsemanAudioEncoderSettings::quality() const
{
    return p->settings.quality();
}

void AsemanAudioEncoderSettings::setQuality(int quality)
{
    if(p->settings.quality() == quality)
        return;

    p->settings.setQuality(static_cast<QMultimedia::EncodingQuality>(quality));
    emit qualityChanged();
}

int AsemanAudioEncoderSettings::sampleRate() const
{
    return p->settings.sampleRate();
}

void AsemanAudioEncoderSettings::setSampleRate(int rate)
{
    if(p->settings.sampleRate() == rate)
        return;

    p->settings.setSampleRate(rate);
    emit sampleRateChanged();
}

QAudioEncoderSettings AsemanAudioEncoderSettings::exportSettings() const
{
    return p->settings;
}

AsemanAudioEncoderSettings::~AsemanAudioEncoderSettings()
{
    delete p;
}

