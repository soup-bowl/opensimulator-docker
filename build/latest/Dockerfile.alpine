FROM alpine:3.21

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

LABEL \
	org.opencontainers.image.title="OpenSimulator (unofficial)" \
	org.opencontainers.image.authors="code@soupbowl.io" \
	org.opencontainers.image.source="https://github.com/soup-bowl/opensimulator-docker" \
	org.opencontainers.image.licenses="MIT"

ENV OPENSIM_VERSION=0.9.3.0

RUN apk add --no-cache curl dotnet8-runtime libgdiplus screen sqlite sqlite-libs uuidgen \
	&& mkdir /opt/opensim-tmp \
	&& curl "http://opensimulator.org/dist/opensim-${OPENSIM_VERSION}.tar.gz"  | tar xzf - -C /opt/opensim-tmp \
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
CMD [ "screen", "-S", "OpenSim", "-D", "-m", "dotnet",  "OpenSim.dll" ]
