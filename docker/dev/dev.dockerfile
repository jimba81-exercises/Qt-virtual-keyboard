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
    wget \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

# Setup Qt Environment
ENV QT_VERSION=5.12.10
ENV DEBIAN_FRONTEND=noninteractive
ENV QT_PATH=/opt/Qt
ENV QT_DESKTOP $QT_PATH/${QT_VERSION}/gcc_64
ENV PATH $QT_DESKTOP/bin:$PATH

# Download Qt Installer and Installer script
RUN mkdir -p /tmp/qt
RUN curl -Lo /tmp/qt/installer.run "https://mirrors.ocf.berkeley.edu/qt/official_releases/qt/$(echo "${QT_VERSION}" | cut -d. -f 1-2)/${QT_VERSION}/qt-opensource-linux-x64-${QT_VERSION}.run"
COPY docker/dev/extract-qt-installer.sh /tmp/qt/

# Install ALL Qt components (including virtual keyboard)
RUN http_proxy=http://127.0.0.1 /tmp/qt/extract-qt-installer.sh /tmp/qt/installer.run "$QT_PATH"

# Link qtcreator
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

# BUILD: (run build command in project root directory)
# docker build . -f docker/dev/dev.dockerfile -t qt-dev:5.12.10 --network=host
# RUN: (run with bash at end if need to configure docker os)
# docker run --rm -it --name qt-dev --network=host --pid=host --env DISPLAY=$DISPLAY -v ${PWD}/workspace:/home/user/workspace -v ~/.bash_history:/home/user/.bash_history qt-dev:5.12.10
# TODO:
# turn the isntall script into a qs file
