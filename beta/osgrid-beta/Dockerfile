FROM docker.io/library/mono:latest

LABEL org.opencontainers.image.title="OpenSimulator (unofficial)"
LABEL org.opencontainers.image.authors="code@soupbowl.io"
LABEL org.opencontainers.image.source="https://github.com/soup-bowl/opensimulator-docker"
LABEL org.opencontainers.image.licenses="MIT"

ENV OPENSIM_VERSION 12272022.v0.9.2.3422ae3

RUN apt-get update && apt-get install -y screen uuid-runtime

RUN mkdir /opt/opensim-tmp \
    && curl "https://danbanner.onikenkon.com/osgrid/osgrid-opensim-${OPENSIM_VERSION}.zip" | unzip - -d /opt/opensim-tmp \
    && rm /opt/opensim-tmp/bin/OpenSim.ini \
    && rm /opt/opensim-tmp/bin/config-include/GridCommon.ini \
    && rm /opt/opensim-tmp/bin/config-include/storage/SQLiteStandalone.ini \
    && mkdir /opt/opensim \
    && mv /opt/opensim-tmp/opensim*/* /opt/opensim

COPY defaults  /opt/opensim/bin/defaults

EXPOSE 9000

WORKDIR /opt/opensim/bin

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "mono", "./OpenSim.exe" ]
