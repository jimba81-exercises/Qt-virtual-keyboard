#========================
# There are two ways to prepare Qt Env: (1)Ubuntu with Qt lib (2)rabits-qt
# Currently, the option(1) doesn't have latest virtualkeyboard library so few layout options (e.g. Chineses) are missing


#========================
# Option1
#FROM ubuntu:20.04 AS ubuntu-qt
#RUN apt-get update && apt-get upgrade -y
#RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
#RUN apt-get install -y git build-essential qt5-default
#RUN apt-get install -y qtdeclarative5-dev qml-module-qtquick-controls qtvirtualkeyboard-plugin qml-module-qtquick-virtualkeyboard libqt5virtualkeyboard5-dev libqt5websockets5-dev qml-module-qt-labs-folderlistmodel 
#RUN apt-get install -y fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core fonts-indic fonts-thai-tlwg-ttf


#========================
# Option2
# Build Qt-Docker image first. Ref: https://hub.docker.com/r/rabits/qt/, https://github.com/rabits/dockerfiles
# In this file, the Qt-Docker image filename is set as 'rabits-qt:x.x'
# ISSUE: the rabits-qt doesn't install virtualkeyboard plugin, the 'extract-qt-installer.sh' had to be modified
FROM rabits-qt:5.12 AS build
RUN mkdir project-src
RUN git clone https://github.com/jimba81/qt-virtualkeyboard-server.git project-src
WORKDIR /home/user/project-src/src
RUN qmake
RUN make

#========================
FROM build AS release
WORKDIR /dist
COPY --from=builder /project-src/qt-virtualkeyboard-server/src .
CMD ./qt-virtualkeyboard-server



# TODO: clean Dockerfile and create own "extract-qt-installer.sh" to include virtualkeyboard plugin

# TODO: Separate Release and Builder Images for lower release image size
# such as:
#   FROM ubuntu:20.04 AS release
#   TODO: Add all qt dependencies including keyboard plugins
#   WORKDIR /dist
#   COPY --from=build /project-src/qt-virtualkeyboard-server/src .
#   CMD ./qt-virtualkeyboard-server

