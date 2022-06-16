FROM ubuntu:18.04 AS base
RUN apt update && apt full-upgrade -y

FROM base AS base-qt
RUN apt install -y --no-install-recommends \
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
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

#======================================
FROM base-qt AS qt-download
ENV QT_VERSION=5.12.10
ENV DEBIAN_FRONTEND=noninteractive \
    QT_PATH=/opt/Qt
ENV QT_DESKTOP $QT_PATH/${QT_VERSION}/gcc_64
ENV PATH $QT_DESKTOP/bin:$PATH
COPY extract-qt-installer.sh /tmp/qt/
RUN curl -Lo /tmp/qt/installer.run "https://mirrors.ocf.berkeley.edu/qt/official_releases/qt/$(echo "${QT_VERSION}" | cut -d. -f 1-2)/${QT_VERSION}/qt-opensource-linux-x64-${QT_VERSION}.run"

FROM qt-download AS qt-install
RUN QT_CI_PACKAGES=qt.qt5.$(echo "${QT_VERSION}" | tr -d .).gcc_64,qt.qt5.$(echo "${QT_VERSION}" | tr -d .).qtvirtualkeyboard.gcc_64,qt.qt5.$(echo "${QT_VERSION}" | tr -d .).qtvirtualkeyboard http_proxy=http://127.0.0.1 /tmp/qt/extract-qt-installer.sh /tmp/qt/installer.run "$QT_PATH"
#WORKDIR $QT_PATH/$QT_VERSION
#RUN ./configure -static
#RUN make