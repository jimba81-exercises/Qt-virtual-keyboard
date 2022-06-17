FROM ubuntu:18.04

# INSTALL NEEDED PACKAGES
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
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

# INSTALL QT
ENV QT_VERSION=5.12.10
ENV DEBIAN_FRONTEND=noninteractive \
    QT_PATH=/opt/Qt
ENV QT_DESKTOP $QT_PATH/${QT_VERSION}/gcc_64
ENV PATH $QT_DESKTOP/bin:$PATH
COPY docker/extract-qt-installer.sh /tmp/qt/
RUN curl -Lo /tmp/qt/installer.run "https://mirrors.ocf.berkeley.edu/qt/official_releases/qt/$(echo "${QT_VERSION}" | cut -d. -f 1-2)/${QT_VERSION}/qt-opensource-linux-x64-${QT_VERSION}.run"
RUN QT_CI_PACKAGES=qt.qt5.$(echo "${QT_VERSION}" | tr -d .).gcc_64,qt.qt5.$(echo "${QT_VERSION}" | tr -d .).qtvirtualkeyboard.gcc_64,qt.qt5.$(echo "${QT_VERSION}" | tr -d .).qtvirtualkeyboard http_proxy=http://127.0.0.1 /tmp/qt/extract-qt-installer.sh /tmp/qt/installer.run "$QT_PATH"

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
WORKDIR /home/user
ENV HOME /home/user

# BUILD:
# docker build . -f docker/dev.dockerfile -t qt-dev:5.12.10 --network=host
# TODO:
# configure sh script for installation - maybe install everything because this can be used for other qt projects