sigram
======

A different telegram client from Sialan.Labs

## How To Build

Tested on Fedora 20. 
### Install dependencies

Fedora: 
```
yum install qt-creator qt5-qtbase qt5-qtbase-devel qt5-qtdeclarative qt5-qtquick1 qt5-qtquick1-devel kde-plasma-applicationname kde-plasma-nm qt5-qtdeclarative-devel qt5-qtdeclarative-static qt5-qtgraphicaleffects
```

For other distributions search for the corresponding packages.

### Generate Makefile

```
mkdir build
cd build
/bin/qmake-qt5 -o Makefile ../SialanTelegram.pro
```

### Compile

```
make
```

### Run
```
./SialanTelegram 
```
