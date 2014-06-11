sigram
======

A different telegram client from Sialan.Labs

## Build

Tested on Fedora 20. 
### Install dependencies
```yum install qt-creator qt5-qtbase qt5-qtbase-devel qt5-qtdeclarative qt5-qtquick1 qt5-qtquick1-devel kde-plasma-applicationname kde-plasma-nm qt5-qtdeclarative-devel qt5-qtdeclarative-static qt5-qtgraphicaleffects```

For other distributions search for the corresponding packages.

### generate makefile
```
mkdir build
cd build
/bin/qmake-qt5 -o Makefile ../SialanTelegram.pro
```

### compile
```make```

###run
```./SialanTelegram ```
