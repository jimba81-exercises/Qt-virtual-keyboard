
# Arguments 
ARG QT_VERSION=5.12.10

# ---- Builder ---
FROM qt-dev:${QT_VERSION} as qt-builder
USER user
WORKDIR /home/user/workspace
COPY --chown=user ./workspace ./
RUN qmake
RUN make
RUN mkdir deploy
RUN cp qt-virtualkeyboard-server deploy/qt-virtualkeyboard-server
COPY --chown=user docker/rel/qt-virtualkeyboard-server.desktop deploy/qt-virtualkeyboard-server.desktop
RUN linuxdeployqt deploy/qt-virtualkeyboard-server -verbose=1 -qmldir=./qml -extra-plugins=virtualkeyboard

# ---- Release ----
FROM ubuntu:18.04 as release
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
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

COPY --chown=user --from=qt-builder /home/user/workspace/deploy ./qt-keyboard-server
CMD ./qt-keyboard-server/AppRun

# BUILD:
# > cd ${PROJECT_PATH}
# > docker build . -f docker/rel/rel.dockerfile -t ${PROJECT_NAME}

# RUN:
# > docker run --rm -it --pid=host -p ${PORT}:3000 -v /tmp/.X11-unix:/tmp/.X11-unix --env DISPLAY=$DISPLAY --name ${PROJECT_NAME} ${PROJECT_NAME}

# TODO:
# Add *.desktop file to the project rather than in docker folder
# Consider using different base images for smaller size
# Copy project rather than git pull from github
# Set port map rather than network=host