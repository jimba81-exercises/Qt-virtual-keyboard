# Arguments 
ARG QT_VERSION=5.12
ARG QT_PLATFORM=desktop

#========================
FROM rabits-qt:${QT_VERSION} AS build
WORKDIR /workspace
COPY ./workspace ./workspace
RUN qmake
RUN make


#========================
FROM build AS release
WORKDIR /dist
COPY --from=builder /project-src/qt-virtualkeyboard-server/src .
CMD ./qt-virtualkeyboard-server


