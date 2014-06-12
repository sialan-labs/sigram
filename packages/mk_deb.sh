#! /bin/sh

BUILD_DIR="deb-build-tmp-`uuidgen`"
QMAKE='qmake'
UNITY_FILE='/usr/bin/unity'
ARCH_INTL=`arch`
VERSION='0.5.4'
DEBIAN_REVISION='1'

if [ "$ARCH_INTL" = "x86_64" ]
then
    ARCHITECTURE="amd64"
else
    ARCHITECTURE="i386"
fi

echo "Welcome to package creator script."
echo "mk_deb script generated on ubuntu 14.04."
echo "This script create deb package of sigram on the $PWD."
echo "If you want to choose another path, you can switch directory using cd command and run script again.
"
echo "Do you want to install dependecies before start build process? (y/n)"
read INST_DEPS
if [ "$INST_DEPS" = "y" ]
then
    if [ -e $UNITY_FILE ]
    then
        echo "Unity founded on your system. Do you install libappindicator plugin too? (y/n)"
        read APP_INDICT
        if [ "$APP_INDICT" = "y" ]
        then
            EXTRA_PACKAGES=" libappindicator-dev libgtk2.0-dev"
        fi
    fi
    
    sudo apt-get install g++ gcc qtbase5-dev libqt5sql5-sqlite libqt5multimediaquick-p5 libqt5multimedia5-plugins libqt5multimedia5 libqt5qml5 libqt5qml-graphicaleffects libqt5qml-quickcontrols qtdeclarative5-dev libqt5quick5 $EXTRA_PACKAGES
fi

echo "Do you want to using multi core compile to improve build speed? (y/n)"
read CORE_QUESTION
if [ "$CORE_QUESTION" = "y" ]
then
    MAKE_JOBS="-j`nproc`"
fi

# Find script directory
if [ "${DATA_PATH}" = "" ]; then
    DATA_PATH="`echo $0 | grep ^/`"
    if [ "$DATA_PATH" = "" ]; then
        DATA_PATH="$PWD"/"$0"
    fi
    DIR="$PWD"
    cd `dirname "$DATA_PATH"`
    DATA_PATH="$PWD"
    cd "$DIR"
fi

# Make build directory
mkdir "$BUILD_DIR"
cd "$BUILD_DIR"

mkdir sigram
cd sigram

# Build Sigram
"$QMAKE" -r "$DATA_PATH"/../
make $MAKE_JOBS
make clean
rm Makefile

# Build UnitySystemTray
mkdir plugins
cd plugins
qmake -r "$DATA_PATH"/../libs/UnitySystemTray
make $MAKE_JOBS
make clean
rm Makefile
cd ..

# Move builded files to /opt
cd ..
mkdir -p ./opt/sialan
mv ./sigram ./opt/sialan/
mv ./opt/sialan/sigram/SialanTelegram ./opt/sialan/sigram/Sigram

# Copy .desktop file
mkdir -p ./usr/share/applications
cp "$DATA_PATH"/../desktop/Sialan-Sigram.desktop ./usr/share/applications/

# Set Persmissons of the files
chmod 755 `find .`
chmod -x `find -type f`
strip --strip-unneeded `find -name "*.so"`

# Set Persmissions of the binary file
mkdir -p ./usr/bin/
ln -s /opt/sialan/sigram/Sigram ./usr/bin/sigram
strip --strip-unneeded ./opt/sialan/sigram/Sigram 
chmod 755 ./opt/sialan/sigram/Sigram
chmod +x ./opt/sialan/sigram/Sigram

# Copy and generate Package details files
cp -r "$DATA_PATH"/DEBIAN .
find . -type f -print0 | xargs -0 md5sum > ./DEBIAN/md5sums.tmp
head -n -4 ./DEBIAN/md5sums.tmp > ./DEBIAN/msd5sum
rm ./DEBIAN/md5sums.tmp
sed -i "s/architecture_keyword/$ARCHITECTURE/g" ./DEBIAN/control
sed -i "s/version_keyword/$VERSION-$DEBIAN_REVISION/g" ./DEBIAN/control

# Package Building
cd ..
echo "Need root to set files permissions to root."
sudo chown -PhR root:root "$BUILD_DIR"
dpkg-deb -b "$BUILD_DIR" sigram_"$VERSION"-"$DEBIAN_REVISION"-"$ARCHITECTURE".deb
echo "Need root to remove extra builded files."
sudo rm -rf "$BUILD_DIR"
