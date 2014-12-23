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

#include "asemanqtlogger.h"

#include <QDebug>
#include <QFile>
#include <QDir>
#include <QDateTime>
#include <QFileInfo>
#include <QCoreApplication>
#include <QMutex>

QSet<AsemanQtLogger*> aseman_qt_logger_objs;

void asemanQtLoggerFnc(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    foreach( AsemanQtLogger *obj, aseman_qt_logger_objs )
        obj->logMsg(type,context,msg);
}

class AsemanQtLoggerPrivate
{
public:
    QFile *file;
    QString path;
    QMutex file_mutex;
};

AsemanQtLogger::AsemanQtLogger(const QString &path, QObject *parent) :
    QObject(parent)
{
    p = new AsemanQtLoggerPrivate;
    p->path = path;

#ifndef Q_OS_UBUNTUTOUCH
    if( QFile::exists(p->path) )
        QFile::copy( p->path, QFileInfo(p->path).dir().path() + "/crash_" + QString::number(QDateTime::currentDateTime().toMSecsSinceEpoch()) );
#endif

    p->file = new QFile(path);
    p->file->open(QFile::WriteOnly);

    aseman_qt_logger_objs.insert(this);
    if( aseman_qt_logger_objs.count() == 1 )
        qInstallMessageHandler(asemanQtLoggerFnc);

    connect( QCoreApplication::instance(), SIGNAL(aboutToQuit()), SLOT(app_closed()) );
}

void AsemanQtLogger::logMsg(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QByteArray localMsg = msg.toLocal8Bit();
    QString text = QString(": (%2:%3, %4) %5 : %1\n").arg(localMsg.constData()).arg(context.file).arg(context.line).arg(context.function).arg(QTime::currentTime().toString());

    switch (type) {
    case QtDebugMsg:
        text = "Debug" + text;
        p->file_mutex.lock();
        p->file->write(text.toUtf8());
        p->file->flush();
        p->file_mutex.unlock();
        break;
    case QtWarningMsg:
        text = "Warning" + text;
        p->file_mutex.lock();
        p->file->write(text.toUtf8());
        p->file->flush();
        p->file_mutex.unlock();
        break;
    case QtCriticalMsg:
        text = "Critical" + text;
        p->file_mutex.lock();
        p->file->write(text.toUtf8());
        p->file->flush();
        p->file_mutex.unlock();
        break;
    case QtFatalMsg:
        text = "Fatal" + text;
        p->file_mutex.lock();
        p->file->write(text.toUtf8());
        p->file->flush();
        p->file_mutex.unlock();
        abort();
    }
}

void AsemanQtLogger::debug(const QVariant &var)
{
    qDebug() << var;
}

void AsemanQtLogger::app_closed()
{
#ifndef Q_OS_UBUNTUTOUCH
    QFile::remove(p->path);
#endif
}

AsemanQtLogger::~AsemanQtLogger()
{
    aseman_qt_logger_objs.remove(this);
    if( aseman_qt_logger_objs.isEmpty() )
        qInstallMessageHandler(0);

    delete p;
}
