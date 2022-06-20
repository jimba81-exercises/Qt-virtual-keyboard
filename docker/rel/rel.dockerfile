FROM qt-dev:5.12.10 as qt-builder

RUN mkdir project-src
RUN git clone https://github.com/jimba81/qt-virtualkeyboard-server.git project-src
WORKDIR /home/user/project-src/src
RUN qmake
RUN make
RUN mkdir deploy
RUN cp qt-virtualkeyboard-server deploy/qt-virtualkeyboard-server
COPY --chown=user docker/rel/qt-virtualkeyboard-server.desktop deploy/qt-virtualkeyboard-server.desktop
RUN linuxdeployqt deploy/qt-virtualkeyboard-server -verbose=1 -qmldir=./qml -extra-plugins=virtualkeyboard

FROM ubuntu:18.04 as release
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt full-upgrade -y
RUN apt install -y --no-install-recommends \
    sudo \
    locales \
    libgl1-mesa-dev \
    libglib2.0-0 \
    libsm6 \
    libice6 \
    libxext6 \
    libxrender1 \
    libxkbcommon-x11-0 \
    libfontconfig1 \
    libdbus-1-3 \
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

COPY --chown=user --from=qt-builder /home/user/project-src/src/deploy ./qt-keyboard-server
CMD ./qt-keyboard-server/AppRun

# CURRENT SIZE: 465MB
# BUILD: (run in project root directory)
# docker build . -f docker/rel/rel.dockerfile -t keyboard-server --network=host
# RUN:
# docker run --rm -it --name keyboard-server --network=host --pid=host --env DISPLAY=$DISPLAY keyboard-server
# TODO:
# add *.desktop file to the project rather than in docker folder
# consider using different base images for smaller size