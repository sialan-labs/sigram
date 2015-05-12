
#Docker builder for debian jessie
#
#Author : pietro abate <pietro.abate@pps.univ-paris-diderot.fr>

#create a docker image
#docker build -t cutegram .
#
#copy the results of the compilation in /tmp
#docker run -i -v /tmp:/output cutegram

FROM debian:jessie
RUN apt-get update
WORKDIR /root

ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes
RUN apt-get install -y build-essential devscripts fakeroot quilt dh-make automake libdistro-info-perl less vim git curl

#build libqtelegram-aseman-edition and install it
RUN git clone https://github.com/Aseman-Land/libqtelegram-aseman-edition.git
RUN apt-get -y install libssl-dev pkg-config qt5-default qtbase5-dev qtmultimedia5-dev cmake
RUN cd libqtelegram-aseman-edition; dpkg-buildpackage -b
RUN dpkg -i libqtelegram-ae_0.2-1aseman1-vivid_amd64.deb  libqtelegram-ae-dev_0.2-1aseman1-vivid_amd64.deb

#build cutegram
RUN apt-get -y install libqt5multimedia5-plugins libqt5qml5 qml-module-qtgraphicaleffects qml-module-qtquick-controls qtdeclarative5-dev libqt5webkit5-dev libappindicator-dev
#RUN git clone https://github.com/Aseman-Land/Cutegram.git
RUN git clone https://github.com/abate/Cutegram.git
RUN cd Cutegram; dpkg-buildpackage -b 

# Create output volume, running the container just copies the 
VOLUME /output
CMD cp *.deb /output
