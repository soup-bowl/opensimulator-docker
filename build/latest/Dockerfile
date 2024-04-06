FROM docker.io/library/mono:latest

LABEL org.opencontainers.image.title="OpenSimulator (unofficial)"
LABEL org.opencontainers.image.authors="code@soupbowl.io"
LABEL org.opencontainers.image.source="https://github.com/soup-bowl/opensimulator-docker"
LABEL org.opencontainers.image.licenses="MIT"

ARG OPENSIM_VERSION=0.9.2.2

RUN apt-get update && apt-get install -y screen uuid-runtime

RUN mkdir /opt/opensim-tmp \
    && curl "http://opensimulator.org/dist/opensim-${OPENSIM_VERSION}.tar.gz" | tar xzf - -C /opt/opensim-tmp \
    && rm /opt/opensim-tmp/opensim*/bin/OpenSim.ini \
    && rm /opt/opensim-tmp/opensim*/bin/config-include/StandaloneCommon.ini \
    && rm /opt/opensim-tmp/opensim*/bin/config-include/storage/SQLiteStandalone.ini \
    && mkdir /opt/opensim \
    && mv /opt/opensim-tmp/opensim*/* /opt/opensim

COPY defaults  /opt/opensim/bin/defaults

EXPOSE 9000

WORKDIR /opt/opensim/bin

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "mono", "./OpenSim.exe" ]
