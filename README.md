### cutegram

A different telegram client from Aseman team.
Cutegram forked from Sigram by Sialan Labs.
Cutegram project are released under the terms of the GPLv3 license.

### How to Compile
#### Install dependencies

Install gcc, g++, openssl, bzr, git, Qt5Core, Qt5DBus, Qt5Gui, Qt5Multimedia, Qt5MultimediaQuick_p, Qt5Network, Qt5PrintSupport, Qt5Qml, Qt5Quick, Qt5Sql, Qt5Svg, and Qt5Widgets.
on Ubuntu:

    sudo apt-get install g++ gcc git bzr qtbase5-dev libqt5sql5-sqlite libqt5multimediaquick-p5 libqt5multimedia5-plugins libqt5multimedia5 libqt5qml5 libqt5qml-graphicaleffects libqt5qml-quickcontrols qtdeclarative5-dev libqt5quick5 

on Fedora (tested on Fedora 20):

    yum install qt5-qtbase qt5-qtbase-devel qt5-qtdeclarative qt5-qtquick1 qt5-qtquick1-devel kde-plasma-applicationname kde-plasma-nm qt5-qtdeclarative-devel qt5-qtdeclarative-static qt5-qtgraphicaleffects qt5-qtquickcontrols openssl-devel libappindicator-devel

Also you should install AppIndicator and Gtk2 if you want to enable UnitySystemTray plugin.

    sudo apt-get install libappindicator-dev libgtk2.0-dev

For other distributions search for the corresponding packages.

#### Get libqtelegtam

First, you should build and install libqtelegtam.

    bzr branch lp:libqtelegram 
    
And:

    cd libqtelegram
    mkdir build && cd build

On Ubuntu 64bit run this cmake command:

    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib/x86_64-linux-gnu/ ..

And on Ubuntu 32bit run:

    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib/i386-linux-gnu/ ..
    
And then start building:

    make
    sudo make install

#### Get source code from git repository

If you want get source from git repository you should install git on your system:

    sudo apt-get install git

After git installed, get code with this command:

    git clone https://github.com/aseman-labs/cutegram.git

#### Start building

Switch to source directory

    cd cutegram

##### Ubuntu

    mkdir build && cd build
    qmake -r .. PREFIX=/usr
    make
    make install

If you want to build UnitySystemTray plugin run this command:

    qmake -r .. EXTENSIONS+=unity PREFIX=/usr
    make
    make install

You can use command below after building to clean build directory on the each step.

    make clean

##### Fedora

    mkdir build && cd build
    /bin/qmake-qt5 -o Makefile ../AsemanTelegram.pro
    make
