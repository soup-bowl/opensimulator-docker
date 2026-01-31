FROM mcr.microsoft.com/dotnet/runtime:8.0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

LABEL \
	org.opencontainers.image.title="OpenSimulator (unofficial)" \
	org.opencontainers.image.authors="code@soupbowl.io" \
	org.opencontainers.image.source="https://github.com/soup-bowl/opensimulator-docker" \
	org.opencontainers.image.licenses="MIT"

ARG OPENSIM_VERSION=0.9.3.0
ARG OPENSIM_SHA1="a4bcd861626195af80cc1f962d3a2f4528859ad2"

RUN apt-get update \
	&& apt-get install --no-install-recommends -y apt-utils curl libc6-dev libgdiplus libsqlite3-dev screen uuid-runtime \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir /opt/opensim-tmp \
	&& curl -o /opt/opensim-tmp/opensim.tar.gz "http://opensimulator.org/dist/opensim-${OPENSIM_VERSION}.tar.gz" \
	&& echo "${OPENSIM_SHA1}  /opt/opensim-tmp/opensim.tar.gz" | sha1sum -c - \
	&& tar xzf /opt/opensim-tmp/opensim.tar.gz -C /opt/opensim-tmp \
	&& rm /opt/opensim-tmp/opensim*/bin/OpenSim.ini \
	&& rm /opt/opensim-tmp/opensim*/bin/config-include/StandaloneCommon.ini \
	&& rm /opt/opensim-tmp/opensim*/bin/config-include/storage/SQLiteStandalone.ini \
	&& mkdir /opt/opensim \
	&& mv /opt/opensim-tmp/opensim*/* /opt/opensim

COPY defaults  /opt/opensim/bin/defaults

EXPOSE 9000

WORKDIR /opt/opensim/bin

COPY docker-entrypoint.sh /usr/local/bin/

ENV \
	OS_BASE_HOSTNAME="localhost" \
	OS_GRID_NAME="My OpenSimulator Grid" \
	OS_GRID_WELCOME="Welcome to my OpenSimulator grid!" \
	OS_REGION_NAME="My Region" \
	OS_ESTATE_NAME="My Estate" \
	OS_ESTATE_OWNER_NAME="Foo Bar" \
	OS_ESTATE_OWNER_UUID="00000000-0000-0000-0000-000000000001" \
	OS_DATABASE_ENGINE="sqlite" \
	OS_MYSQL_SERVER="localhost" \
	OS_MYSQL_DATABASE="opensim" \
	OS_MYSQL_USERNAME="opensim" \
	OS_PHYSICS_ENGINE="OpenDynamicsEngine"
# - OS_ESTATE_OWNER_PASSWORD
# - OS_MYSQL_PASSWORD

ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "screen", "-S", "OpenSim", "-D", "-m", "dotnet",  "OpenSim.dll" ]
