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
RUN find "$QT_PATH" -mindepth 1 -maxdepth 1 ! -name "${QT_VERSION}" -exec echo 'Cleaning Qt SDK: {}' \; -exec rm -r '{}' \; \
  && rm -rf /tmp/qt

FROM qt-install AS qt-setup
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
RUN groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user
USER user
WORKDIR /home/user
ENV HOME /home/user

FROM qt-setup AS qt-build
RUN mkdir project-src
RUN git clone https://github.com/jimba81/qt-virtualkeyboard-server.git project-src
WORKDIR /home/user/project-src/src
RUN qmake
RUN make

FROM qt-build AS release
RUN sudo apt-get update && sudo apt-get upgrade -y
RUN sudo apt-get install -y fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core fonts-indic fonts-thai-tlwg-ttf
CMD ./qt-virtualkeyboard-server

# TODO: Separate Release and Builder Images for lower release image size
# TODO: clean Dockerfile and create own "extract-qt-installer.sh" to include virtualkeyboard plugin

# docker run --rm -it --network host --pid=host --env DISPLAY=$DISPLAY --name keyboard-server keyboard-server
# host:
#   sudo apt-get install xorg xauth
#   xhost local:root