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

#define EARTH_GRAVITY 9.80665

#include "asemansensors.h"

#include <QtMath>
#include <QDebug>
#include <QRotationSensor>
#include <QGyroscope>
#include <QAccelerometer>
#include <QTimerEvent>
#include <QMatrix4x4>
#include <QTransform>

class AsemanSensorsResItem
{
public:
    qreal newX;
    qreal beta;
    qreal alpha;
    qreal g;
    qreal f;
};

class ProVector
{
public:
    ProVector() {
        x = 0;
        y = 0;
        z = 0;
    }

    qreal x;
    qreal y;
    qreal z;
};

class AsemanSensorsPrivate
{
public:
    qreal alp;

    QAccelerometer *gravity;
    QAccelerometer *accelerometer;

    QRotationSensor *rotation;
    QGyroscope *gyroscope;

    ProVector pg_vector;
    ProVector pa_vector;
    ProVector pr_vector;

    ProVector g_vector;
    ProVector a_vector;
    ProVector r_vector;

    ProVector gyr_vector;

    int duration_timer;
    int duration;

    int activeSensors;

    qreal zeroX;
    qreal zeroY;
    qreal zeroZ;
};

AsemanSensors::AsemanSensors(QObject *parent) :
    QObject(parent)
{
    p = new AsemanSensorsPrivate;
    p->alp = 0;
    p->duration_timer = 0;
    p->duration = 200;
    p->zeroX = 0;
    p->zeroY = 0;
    p->zeroZ = 0;
    p->activeSensors = RotationSensor | AccelerometerSensor | GravitySensor;

    p->gravity = new QAccelerometer(this);
    p->gravity->setAccelerationMode(QAccelerometer::Gravity);

    p->accelerometer = new QAccelerometer(this);

    p->rotation = new QRotationSensor(this);
    p->gyroscope = new QGyroscope(this);

    const qreal ax = -1.93166;
    const qreal ay = 3.28901;
    const qreal az = 9.31951;

    const qreal rx = 18.5109;
    const qreal ry = 11.3424;
    const qreal rz = -46.1778;

    const AsemanSensorsResItem & resX0 = analizeItem(ay,ax,az,false);

    qDebug() << resX0.beta*180/M_PI << resX0.newX << resX0.alpha*180/M_PI << "\n"
             << ax << ay << az << "\n"
             << rx << ry << rz;

    connect( p->gravity      , SIGNAL(readingChanged()), SLOT(grv_reading()) );
    connect( p->accelerometer, SIGNAL(readingChanged()), SLOT(acc_reading()) );
    connect( p->rotation     , SIGNAL(readingChanged()), SLOT(rtt_reading()) );
    connect( p->gyroscope    , SIGNAL(readingChanged()), SLOT(gyr_reading()) );
}

qreal AsemanSensors::ax() const
{
    return p->a_vector.x;
}

qreal AsemanSensors::ay() const
{
    return p->a_vector.y;
}

qreal AsemanSensors::az() const
{
    return p->a_vector.z;
}

qreal AsemanSensors::gx() const
{
    return p->g_vector.x;
}

qreal AsemanSensors::gy() const
{
    return p->g_vector.y;
}

qreal AsemanSensors::gz() const
{
    return p->g_vector.z;
}

qreal AsemanSensors::angleX() const
{
    return p->r_vector.x-p->zeroX*180/M_PI;
}

qreal AsemanSensors::angleY() const
{
    return p->r_vector.y-p->zeroY*180/M_PI;
}

qreal AsemanSensors::angleZ() const
{
    return p->r_vector.z-p->zeroZ*180/M_PI;
}

qreal AsemanSensors::zeroAngleX() const
{
    return p->zeroX*180/M_PI;
}

qreal AsemanSensors::zeroAngleY() const
{
    return p->zeroY*180/M_PI;
}

qreal AsemanSensors::zeroAngleZ() const
{
    return p->zeroZ*180/M_PI;
}

qreal AsemanSensors::angleSpeedX() const
{
    return p->gyr_vector.x;
}

qreal AsemanSensors::angleSpeedY() const
{
    return p->gyr_vector.y;
}

qreal AsemanSensors::angleSpeedZ() const
{
    return p->gyr_vector.z;
}

void AsemanSensors::setDuration(int ms)
{
    if( p->duration == ms )
        return;

    p->duration = ms;
    if( active() )
        start();

    emit durationChanged();
}

int AsemanSensors::duration() const
{
    return p->duration;
}

void AsemanSensors::setActive(bool stt)
{
    if( stt == active() )
        return;

    if( stt )
        start();
    else
        stop();
}

bool AsemanSensors::active() const
{
    return p->duration_timer;
}

void AsemanSensors::setActiveSensors(int t)
{
    if( p->activeSensors == t )
        return;

    p->activeSensors = t;
    if( !active() )
        return;

    if( t & RotationSensor )
    {
        p->rotation->setActive(true);
        p->rotation->start();
    }
    if( t & AccelerometerSensor )
    {
        p->accelerometer->setActive(true);
        p->accelerometer->start();
    }
    if( t & GravitySensor )
    {
        p->gravity->setActive(true);
        p->gravity->start();
    }
    if( t & GyroscopeSensor )
    {
        p->gyroscope->setActive(true);
        p->gyroscope->start();
    }

    emit activeSensorsChanged();
}

int AsemanSensors::activeSensors() const
{
    return p->activeSensors;
}

void AsemanSensors::start()
{
    if( p->duration_timer )
        killTimer( p->duration_timer );

    p->accelerometer->setActive(true);
    p->accelerometer->start();

    p->gravity->setActive(true);
    p->gravity->start();

    p->rotation->setActive(true);
    p->rotation->start();

    p->gyroscope->setActive(true);
    p->gyroscope->start();

    p->duration_timer = startTimer(p->duration);
    emit activeChanged();
}

void AsemanSensors::stop()
{
    if( p->duration_timer )
        killTimer( p->duration_timer );

    p->accelerometer->setActive(false);
    p->accelerometer->stop();

    p->gravity->setActive(false);
    p->gravity->stop();

    p->duration_timer = 0;
    emit activeChanged();
}

void AsemanSensors::zero()
{
    p->zeroX = p->r_vector.x*M_PI/180;
    p->zeroY = p->r_vector.y*M_PI/180;
    p->zeroZ = p->r_vector.z*M_PI/180;

    refresh();

    emit accChanged();
    emit grvChanged();
    emit angleChanged();
    emit angleSpeedChanged();
}

void AsemanSensors::setZero(qreal xrad, qreal yrad)
{
    p->zeroX = xrad;
    p->zeroY = yrad;

    refresh();

    emit accChanged();
    emit grvChanged();
    emit angleChanged();
    emit angleSpeedChanged();
}

void AsemanSensors::refresh()
{
    p->r_vector.x = p->pr_vector.x;
    p->r_vector.y = p->pr_vector.y;
    p->r_vector.z = p->pr_vector.z;

    p->a_vector = rebase(p->pa_vector);
    p->g_vector = rebase(p->pg_vector);

    return;
    const AsemanSensorsResItem & resX0 = analizeItem(p->a_vector.x,p->a_vector.y,p->a_vector.z,false);
    const AsemanSensorsResItem & resY0 = analizeItem(p->a_vector.y,p->a_vector.x,p->a_vector.z,false);

    const AsemanSensorsResItem & resX1 = analizeItem(p->a_vector.x,p->a_vector.y,p->a_vector.z,true);
    const AsemanSensorsResItem & resY1 = analizeItem(p->a_vector.y,p->a_vector.x,p->a_vector.z,true);

    AsemanSensorsResItem resX;
    if( qAbs(qAbs(90-resX0.beta*180/M_PI)-qAbs(angleY())) < qAbs(qAbs(90-resX1.beta*180/M_PI)-qAbs(angleY())) )
        resX = resX0;
    else
        resX = resX1;

    AsemanSensorsResItem resY;
    if( qAbs(qAbs(90-resY0.beta*180/M_PI)-qAbs(angleX())) < qAbs(qAbs(90-resY1.beta*180/M_PI)-qAbs(angleX())) )
        resY = resY0;
    else
        resY = resY1;

    int rvector_x_sign = angleX()<0? -1 : 1;
    int rvector_y_sign = angleY()<0? -1 : 1;

    p->r_vector.x = rvector_x_sign*(M_PI/2-resY.beta)*180/M_PI + p->zeroX*M_PI/180;
    p->r_vector.y = rvector_y_sign*(M_PI/2-resX.beta)*180/M_PI + p->zeroY*M_PI/180;

    p->a_vector.x = resX.newX;
    p->a_vector.y = resY.newX;
}

ProVector AsemanSensors::rebase(const ProVector &v)
{
    ProVector res;

    const qreal x = v.x;
    const qreal y = v.y;
    const qreal z = v.z;

    QMatrix4x4 m;
    m.rotate(p->zeroX*180/M_PI,1,0,0);
    m.rotate(p->zeroY*180/M_PI,0,1,0);

    const QVector3D & v3d = m.map(QVector3D(x,y,z));

    res.x = v3d.x();
    res.y = v3d.y();
    res.z = v3d.z();

    return res;
}

AsemanSensorsResItem AsemanSensors::analizeItem(qreal x, qreal y, qreal z, bool ambiguity)
{
    AsemanSensorsResItem res;
    res.beta = 0;
    res.newX = 0;

    const qreal f = qPow(x*x+z*z,0.5);
    if( f == 0 )
        return res;

    const qreal al = qAsin(z/f);

    const qreal g   = EARTH_GRAVITY;
    const qreal gxz = x==0 && y==0? 0 : pow( (x*x*g*g+z*z*y*y)/(x*x+y*y), 0.5 );

    const qreal sinb = z/gxz;
    const qreal bt_p = qAsin( sinb>1?1:(sinb<-1?-1:sinb) );
    const qreal bt   = ambiguity? M_PI-bt_p : bt_p;
    const qreal nx   = x - gxz*qCos(bt);

    res.beta = bt;
    res.newX = nx;
    res.f = f;
    res.g = gxz;
    res.alpha = al;

    return res;
}

void AsemanSensors::acc_reading()
{
    if( !p->accelerometer->reading() )
        return;

    QAccelerometerReading *rd = p->accelerometer->reading();
    p->pa_vector.x = rd->x();
    p->pa_vector.y = rd->y();
    p->pa_vector.z = rd->z();
    refresh();
}

void AsemanSensors::grv_reading()
{
    if( !p->gravity->reading() )
        return;

    QAccelerometerReading *rd = p->gravity->reading();
    p->pg_vector.x = rd->x();
    p->pg_vector.y = rd->y();
    p->pg_vector.z = rd->z();
    refresh();
}

void AsemanSensors::rtt_reading()
{
    if( !p->gravity->reading() )
        return;

    QRotationReading *rd = p->rotation->reading();
    p->pr_vector.x = rd->x();
    p->pr_vector.y = rd->y();
    p->pr_vector.z = rd->z();
    refresh();
}

void AsemanSensors::gyr_reading()
{
    if( !p->gyroscope->reading() )
        return;

    QGyroscopeReading *rd = p->gyroscope->reading();
    p->gyr_vector.x = rd->x();
    p->gyr_vector.y = rd->y();
    p->gyr_vector.z = rd->z();
    refresh();
}

void AsemanSensors::timerEvent(QTimerEvent *e)
{
    if( e->timerId() == p->duration_timer )
    {
        emit accChanged();
        emit grvChanged();
        emit angleChanged();
        emit angleSpeedChanged();
        emit updated();

//        qDebug() << p->a_vector.x << p->a_vector.y << p->a_vector.z
//                 << angleX() << angleY() << angleZ();
    }
    else
        QObject::timerEvent(e);
}

AsemanSensors::~AsemanSensors()
{
    delete p;
}
