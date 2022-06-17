FROM qt-dev:5.12.10 as qt-builder
#RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
RUN groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user
USER user
WORKDIR /home/user
ENV HOME /home/user

RUN mkdir project-src
RUN git clone https://github.com/jimba81/qt-virtualkeyboard-server.git project-src
WORKDIR /home/user/project-src/src
RUN qmake
RUN make

USER root
RUN apt update && apt install -y wget
WORKDIR /home/user/
RUN wget https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage
RUN chmod +x linuxdeployqt-continuous-x86_64.AppImage
RUN ./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
RUN mv squashfs-root deployqt
RUN chmod +x deployqt/AppRun
RUN ln -s /home/user/deployqt/AppRun /usr/local/sbin/linuxdeployqt
RUN rm -f linuxdeployqt-continuous-x86_64.AppImage

USER user
WORKDIR /home/user/project-src/src
RUN mkdir deploy
RUN cp qt-virtualkeyboard-server deploy/qt-virtualkeyboard-server
COPY --chown=user qt-virtualkeyboard-server.desktop deploy/qt-virtualkeyboard-server.desktop
RUN linuxdeployqt deploy/qt-virtualkeyboard-server -verbose=1 -qmldir=./qml

FROM ubuntu:18.04 as release

RUN apt update && apt full-upgrade -y
RUN apt install -y --no-install-recommends \
    sudo \
    locales \
    build-essential \
    pkg-config \
    libgl1-mesa-dev \
    libsm6 \
    libice6 \
    libxext6 \
    libxrender1 \
    libxkbcommon-x11-0 \
    libfontconfig1 \
    libdbus-1-3 \
    libgl1-mesa-dev \
    fonts-arphic-ukai \
    fonts-arphic-uming \
    fonts-ipafont-mincho \
    fonts-ipafont-gothic \
    fonts-unfonts-core \
    fonts-indic \
    fonts-thai-tlwg-ttf \
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
RUN groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user
USER user
WORKDIR /home/user
ENV HOME /home/user

COPY --chown=user --from=qt-builder /home/user/project-src/src/deploy ./deploy
CMD ./deploy/AppRun
