FROM ubuntu:18.04

# Install needed OS packages
RUN apt-get update && apt full-upgrade -y
RUN apt-get install -y --no-install-recommends \
    git \
    openssh-client \
    ca-certificates \
    locales \
    sudo \
    curl \
    wget \
    build-essential \
    pkg-config \
    libxrender-dev \
    libxcb-render0-dev \
    libxcb-render-util0-dev \
    libxcb-shape0-dev \
    libxcb-randr0-dev \
    libxcb-xfixes0-dev \
    libxcb-sync-dev \
    libxcb-shm0-dev \
    libxcb-icccm4-dev \
    libxcb-keysyms1-dev \
    libxcb-image0-dev \
    libxcb-xinerama0-dev \
    libxkbcommon-x11-dev \
    libfontconfig-dev \
    libfreetype6-dev \
    libxi-dev \
    libxext-dev \
    libx11-dev \
    libxcb1-dev \
    libx11-xcb-dev \
    libsm-dev \
    libice-dev \
    libglib2.0-dev \
    libpthread-workqueue-dev \
    libdbus-1-dev \
    libgl1-mesa-dev \
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

# Setup Qt Environment
ENV QT_VERSION=5.12.10
ENV DEBIAN_FRONTEND=noninteractive
ENV QT_PATH=/opt/Qt
ENV QT_DESKTOP $QT_PATH/${QT_VERSION}/gcc_64
ENV PATH $QT_DESKTOP/bin:$PATH

# Download Qt Installer
RUN mkdir -p /tmp/qt
RUN curl -Lo /tmp/qt/installer.run "https://mirrors.ocf.berkeley.edu/qt/official_releases/qt/$(echo "${QT_VERSION}" | cut -d. -f 1-2)/${QT_VERSION}/qt-opensource-linux-x64-${QT_VERSION}.run"
RUN chmod u+x /tmp/qt/installer.run

# Install ALL Qt components and setup QtCreator
COPY docker/dev/qt-installer.qs /tmp/qt/
RUN http_proxy=http://127.0.0.1 QT_QPA_PLATFORM=minimal /tmp/qt/installer.run -v --script /tmp/qt/qt-installer.qs
RUN ln -s ${QT_PATH}/Tools/QtCreator/bin/qtcreator /usr/local/sbin/qtcreator

# Reconfigure locale and create user
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
RUN groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

# SETUP LINUXDEPLOYQT
WORKDIR /home/user/
RUN wget https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage
RUN chmod +x linuxdeployqt-continuous-x86_64.AppImage
RUN ./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
RUN mv squashfs-root deployqt
RUN chmod +x deployqt/AppRun
RUN ln -s /home/user/deployqt/AppRun /usr/local/sbin/linuxdeployqt
RUN rm -f linuxdeployqt-continuous-x86_64.AppImage

USER user
ENV HOME /home/user
WORKDIR /home/user/workspace

CMD qtcreator

# BUILD:
# > cd ${PROJECT_PATH}
# > QT_VERSION=5.12.10; docker build . -f docker/dev/dev.dockerfile -t qt-dev:${QT_VERSION} --network=host

# RUN:
# > xhost local:root
# > docker run --rm -it --name qt-dev --network=host --pid=host --env DISPLAY=$DISPLAY -v ${PWD}/workspace:/home/user/workspace -v ~/.bash_history:/home/user/.bash_history qt-dev:${QT_VERSION}

# Reference:
# Qt X11 dependencies - https://doc.qt.io/archives/qt-5.12/linux-requirements.html

