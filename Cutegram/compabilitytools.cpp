#include "compabilitytools.h"
#include "asemantools/asemanapplication.h"

#include <QDir>
#include <QCoreApplication>
#include <QFileInfo>
#include <QFile>

void CompabilityTools::version1()
{
    const QString & oldProfile = QDir::homePath() + "/.config/" + QCoreApplication::organizationDomain().toLower() + "." + QCoreApplication::applicationName().toLower();
    QFileInfo oldFile(oldProfile);

    const QString & newProfile = AsemanApplication::homePath();
    QFileInfo newFile(newProfile);
    if(!oldFile.exists() || newFile.exists())
        return;
    if(oldFile.isFile())
        return;

    QDir oldDir(oldProfile);
    oldDir.rename(oldProfile, newProfile);
}
