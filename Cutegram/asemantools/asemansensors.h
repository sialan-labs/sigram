/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef ASEMANSENSORS_H
#define ASEMANSENSORS_H

#include <QObject>

class AsemanSensorsPrivate;
class AsemanSensors : public QObject
{
    Q_OBJECT

    Q_PROPERTY(qreal ax READ ax NOTIFY accChanged)
    Q_PROPERTY(qreal ay READ ay NOTIFY accChanged)
    Q_PROPERTY(qreal az READ az NOTIFY accChanged)

    Q_PROPERTY(qreal gx READ gx NOTIFY grvChanged)
    Q_PROPERTY(qreal gy READ gy NOTIFY grvChanged)
    Q_PROPERTY(qreal gz READ gz NOTIFY grvChanged)

    Q_PROPERTY(qreal angleX READ angleX NOTIFY angleChanged)
    Q_PROPERTY(qreal angleY READ angleY NOTIFY angleChanged)
    Q_PROPERTY(qreal angleZ READ angleZ NOTIFY angleChanged)

    Q_PROPERTY(qreal zeroAngleX READ zeroAngleX NOTIFY zeroChanged)
    Q_PROPERTY(qreal zeroAngleY READ zeroAngleY NOTIFY zeroChanged)
    Q_PROPERTY(qreal zeroAngleZ READ zeroAngleZ NOTIFY zeroChanged)

    Q_PROPERTY(qreal angleSpeedX READ angleSpeedX NOTIFY angleSpeedChanged)
    Q_PROPERTY(qreal angleSpeedY READ angleSpeedY NOTIFY angleSpeedChanged)
    Q_PROPERTY(qreal angleSpeedZ READ angleSpeedZ NOTIFY angleSpeedChanged)

    Q_PROPERTY(int  duration      READ duration      WRITE setDuration      NOTIFY durationChanged      )
    Q_PROPERTY(bool active        READ active        WRITE setActive        NOTIFY activeChanged        )
    Q_PROPERTY(int  activeSensors READ activeSensors WRITE setActiveSensors NOTIFY activeSensorsChanged )

    Q_ENUMS(SensorType)

public:
    AsemanSensors(QObject *parent = 0);
    ~AsemanSensors();

    enum SensorType {
        RotationSensor      = 1,
        GravitySensor       = 2,
        AccelerometerSensor = 4,
        GyroscopeSensor     = 8,
        AllSensors          = 15
    };

    qreal ax() const;
    qreal ay() const;
    qreal az() const;

    qreal gx() const;
    qreal gy() const;
    qreal gz() const;

    qreal angleX() const;
    qreal angleY() const;
    qreal angleZ() const;

    qreal zeroAngleX() const;
    qreal zeroAngleY() const;
    qreal zeroAngleZ() const;

    qreal angleSpeedX() const;
    qreal angleSpeedY() const;
    qreal angleSpeedZ() const;

    void setDuration( int ms );
    int duration() const;

    void setActive( bool stt );
    bool active() const;

    void setActiveSensors( int t );
    int activeSensors() const;

public slots:
    void start();
    void stop();

    void zero();
    void setZero(qreal xrad, qreal zrad );

    void refresh();

signals:
    void accChanged();
    void grvChanged();
    void angleChanged();
    void zeroChanged();
    void angleSpeedChanged();
    void durationChanged();
    void activeChanged();
    void activeSensorsChanged();
    void updated();

private slots:
    void acc_reading();
    void grv_reading();
    void rtt_reading();
    void gyr_reading();

private:
    class ProVector rebase(const class ProVector & v );
    class AsemanSensorsResItem analizeItem(qreal x, qreal y , qreal z, bool ambiguity = false);

protected:
    void timerEvent( QTimerEvent *e );

private:
    AsemanSensorsPrivate *p;
};

#endif // ASEMANSENSORS_H
