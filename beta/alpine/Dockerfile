FROM alpine:3.16

LABEL org.opencontainers.image.title="OpenSimulator (unofficial)"
LABEL org.opencontainers.image.authors="code@soupbowl.io"
LABEL org.opencontainers.image.source="https://github.com/soup-bowl/opensimulator-docker"
LABEL org.opencontainers.image.licenses="MIT"

RUN apk add --no-cache curl uuidgen screen
RUN apk add --no-cache mono --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing

RUN mkdir /opt/opensim-tmp \
    && curl http://opensimulator.org/dist/opensim-0.9.2.1.tar.gz | tar xzf - -C /opt/opensim-tmp \
    && rm /opt/opensim-tmp/opensim*/bin/OpenSim.ini \
    && rm /opt/opensim-tmp/opensim*/bin/config-include/StandaloneCommon.ini \
    && mkdir /opt/opensim \
    && mv /opt/opensim-tmp/opensim*/* /opt/opensim

COPY defaults  /opt/opensim/bin/defaults

EXPOSE 9000

# Down the bottom here while dependencies are an ongoing investigation.
RUN apk add --no-cache libgdiplus sqlite sqlite-libs

WORKDIR /opt/opensim/bin

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "mono", "./OpenSim.exe" ]