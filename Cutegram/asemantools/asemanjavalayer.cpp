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

#include "asemanjavalayer.h"

#include <QDebug>
#include <QAndroidJniEnvironment>
#include <QAndroidJniObject>
#include <QSet>
#include <QPair>
#include <QList>
#include <QDateTime>
#include <QFile>
#include <QCoreApplication>
#include <QTimer>
#include <QScreen>
#include <QGuiApplication>

#include <jni.h>

QSet<AsemanJavaLayer*> java_layers_objects;
QList< QPair<QString,QString> > java_layer_inc_share_buffer;
QList< QString > java_layer_inc_image_buffer;

class AsemanJavaLayerPrivate
{
public:
    QAndroidJniObject object;
    QAndroidJniEnvironment env;
};

AsemanJavaLayer::AsemanJavaLayer() :
    QObject()
{
    p = new AsemanJavaLayerPrivate;
    p->object = QAndroidJniObject("land/aseman/android/AsemanJavaLayer");

    java_layers_objects.insert(this);
    QMetaObject::invokeMethod( this, "load_buffer", Qt::QueuedConnection );
}

AsemanJavaLayer *AsemanJavaLayer::instance()
{
    static AsemanJavaLayer *java_layer_instance = 0;
    if( !java_layer_instance )
    {
        java_layer_instance = new AsemanJavaLayer();
        QObject::connect( QCoreApplication::instance(), SIGNAL(destroyed()), java_layer_instance, SLOT(deleteLater()) );
    }

    return java_layer_instance;
}

bool AsemanJavaLayer::sharePaper(const QString &title, const QString &msg)
{
    jstring jtitle = p->env->NewString(reinterpret_cast<const jchar*>(title.constData()), title.length());
    jstring jmsg   = p->env->NewString(reinterpret_cast<const jchar*>(msg.constData()), msg.length());
    jboolean res = p->object.callMethod<jboolean>(__FUNCTION__, "(Ljava/lang/String;Ljava/lang/String;)Z", jtitle, jmsg );
    return res;
}

bool AsemanJavaLayer::shareFile(const QString &path, const QString &type)
{
    jstring jpath = p->env->NewString(reinterpret_cast<const jchar*>(path.constData()), path.length());
    jstring jtype = p->env->NewString(reinterpret_cast<const jchar*>(type.constData()), type.length());
    jboolean res = p->object.callMethod<jboolean>(__FUNCTION__, "(Ljava/lang/String;Ljava/lang/String;)Z", jpath, jtype );
    return res;
}

bool AsemanJavaLayer::openFile(const QString &path, const QString &type)
{
    jstring jpath = p->env->NewString(reinterpret_cast<const jchar*>(path.constData()), path.length());
    jstring jtype = p->env->NewString(reinterpret_cast<const jchar*>(type.constData()), type.length());
    jboolean res = p->object.callMethod<jboolean>(__FUNCTION__, "(Ljava/lang/String;Ljava/lang/String;)Z", jpath, jtype );
    return res;
}

bool AsemanJavaLayer::startCamera(const QString &output)
{
    jstring joutput = p->env->NewString(reinterpret_cast<const jchar*>(output.constData()), output.length());
    jboolean res = p->object.callMethod<jboolean>(__FUNCTION__, "(Ljava/lang/String;)Z", joutput );
    return res;
}

bool AsemanJavaLayer::getOpenPictures()
{
    jboolean res = p->object.callMethod<jboolean>(__FUNCTION__, "()Z");
    return res;
}

bool AsemanJavaLayer::transparentStatusBar()
{
    jboolean res = p->object.callMethod<jboolean>(__FUNCTION__, "()Z");
    return res;
}

bool AsemanJavaLayer::transparentNavigationBar()
{
    jboolean res = p->object.callMethod<jboolean>(__FUNCTION__, "()Z");
    return res;
}

bool AsemanJavaLayer::startService()
{
    jboolean res = p->object.callMethod<jboolean>(__FUNCTION__, "()Z" );
    return res;
}

bool AsemanJavaLayer::stopService()
{
    jboolean res = p->object.callMethod<jboolean>(__FUNCTION__, "()Z" );
    return res;
}

int AsemanJavaLayer::densityDpi()
{
    jint res = p->object.callMethod<jint>(__FUNCTION__, "()I" );
    return res;
}

int AsemanJavaLayer::getSizeName()
{
    jint res = p->object.callMethod<jint>(__FUNCTION__, "()I" );
    return res;
}

bool AsemanJavaLayer::isTablet()
{
    jboolean res = p->object.callMethod<jboolean>(__FUNCTION__, "()Z");
    return res;
}

qreal AsemanJavaLayer::density()
{
    jfloat res = p->object.callMethod<jfloat>(__FUNCTION__, "()F" );
    return res;
}

QRect AsemanJavaLayer::keyboardRect()
{
    jint jheight = p->object.callMethod<jfloat>("menuHeight", "()I" );
    int menuheight = jheight;

    const QList<QScreen*> & screens = QGuiApplication::screens();
    if( screens.isEmpty() )
        return QRect();

    qDebug() << menuheight;

    QScreen *screen = screens.first();
    QRect rect = screen->availableGeometry();
    QRect geom = screen->geometry();

    rect.moveTop(rect.top() + menuheight);
    geom.setTop(geom.top() + menuheight);

    QRect final;

    if (rect != geom)
    {
        int ftop, fleft, fwidth, fheight;

        geom.getRect(&fleft, &ftop, &fwidth, &fheight);

        if (rect.top() != ftop)
            fheight = rect.top();
        else if (rect.left() != fleft)
            fwidth = rect.left();
        else if (rect.height() != fheight)
            ftop = rect.height();
        else if (rect.width() != fwidth)
            fleft = rect.width();

        final = QRect(fleft, ftop, fwidth - fleft, fheight - ftop);
    }

    return final;
}

void AsemanJavaLayer::load_buffer()
{
    while( !java_layer_inc_share_buffer.isEmpty() )
    {
        const QPair<QString,QString> & pair = java_layer_inc_share_buffer.takeFirst();
        emit incomingShare( pair.first, pair.second );
    }
}

AsemanJavaLayer::~AsemanJavaLayer()
{
    java_layers_objects.remove(this);
    delete p;
}

static void noteRecieved( JNIEnv *env, jobject obj ,jstring title, jstring msg )
{
    Q_UNUSED(obj)
    jboolean a;
    jboolean b;
    const char *t = env->GetStringUTFChars(title,&a);
    const char *m = env->GetStringUTFChars(msg,&b);

    foreach( AsemanJavaLayer *sjl, java_layers_objects )
        emit sjl->incomingShare( QString(t), QString(m) );

    if( java_layers_objects.isEmpty() )
        java_layer_inc_share_buffer << QPair<QString,QString>( QString(t), QString(m) );
}

static void imageRecieved( JNIEnv *env, jobject obj ,jstring jpath )
{
    Q_UNUSED(obj)
    jboolean a;
    const char *p = env->GetStringUTFChars(jpath,&a);

    QString path = QString("/sdcard/Aseman/%1.jpeg").arg(QDateTime::currentDateTime().toMSecsSinceEpoch());
    QFile().rename(QString(p),path);

    foreach( AsemanJavaLayer *sjl, java_layers_objects )
        emit sjl->incomingImage(path);

    if( java_layers_objects.isEmpty() )
        java_layer_inc_image_buffer << path;
}

static void selectImageResult( JNIEnv *env, jobject obj ,jstring path )
{
    Q_UNUSED(obj)
    jboolean a;
    const char *p = env->GetStringUTFChars(path,&a);

    foreach( AsemanJavaLayer *sjl, java_layers_objects )
        emit sjl->selectImageResult( QString(p) );
}

static void activityPaused( JNIEnv *env, jobject obj )
{
    Q_UNUSED(env)
    Q_UNUSED(obj)
    foreach( AsemanJavaLayer *sjl, java_layers_objects )
        emit sjl->activityPaused();
}

static void activityStopped( JNIEnv *env, jobject obj )
{
    Q_UNUSED(env)
    Q_UNUSED(obj)
    foreach( AsemanJavaLayer *sjl, java_layers_objects )
        emit sjl->activityStopped();
}

static void activityResumed( JNIEnv *env, jobject obj )
{
    Q_UNUSED(env)
    Q_UNUSED(obj)
    foreach( AsemanJavaLayer *sjl, java_layers_objects )
        emit sjl->activityResumed();
}

static void activityStarted( JNIEnv *env, jobject obj )
{
    Q_UNUSED(env)
    Q_UNUSED(obj)
    foreach( AsemanJavaLayer *sjl, java_layers_objects )
        emit sjl->activityStarted();
}

static void activityRestarted( JNIEnv *env, jobject obj )
{
    Q_UNUSED(env)
    Q_UNUSED(obj)
    foreach( AsemanJavaLayer *sjl, java_layers_objects )
        emit sjl->activityRestarted();
}

bool registerNativeMethods() {
    JNINativeMethod methods[] {{"_sendNote", "(Ljava/lang/String;Ljava/lang/String;)V", reinterpret_cast<void *>(noteRecieved)},
                               {"_sendImage", "(Ljava/lang/String;)V", reinterpret_cast<void *>(imageRecieved)},
                               {"_selectImageResult", "(Ljava/lang/String;)V", reinterpret_cast<void *>(selectImageResult)},
                               {"_activityPaused", "()V", reinterpret_cast<void *>(activityPaused)},
                               {"_activityStopped", "()V", reinterpret_cast<void *>(activityStopped)},
                               {"_activityResumed", "()V", reinterpret_cast<void *>(activityResumed)},
                               {"_activityStarted", "()V", reinterpret_cast<void *>(activityStarted)},
                               {"_activityRestarted", "()V", reinterpret_cast<void *>(activityRestarted)}};

    QAndroidJniObject javaClass("land/aseman/android/AsemanJavaLayer");
    QAndroidJniEnvironment env;
    jclass objectClass = env->GetObjectClass(javaClass.object<jobject>());

    env->RegisterNatives(objectClass, methods, sizeof(methods) / sizeof(methods[0]));

    env->DeleteLocalRef(objectClass);
    return true;
}

const bool native_methods_registered = registerNativeMethods();
