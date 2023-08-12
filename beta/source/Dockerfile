FROM mcr.microsoft.com/dotnet/sdk:6.0 as build

RUN git clone git://opensimulator.org/git/opensim /app
WORKDIR /app
RUN git checkout dotnet6

RUN ./runprebuild.sh && ./compile.sh

RUN rm bin/config-include/storage/SQLiteStandalone.ini

FROM mcr.microsoft.com/dotnet/runtime:6.0

LABEL org.opencontainers.image.title="OpenSimulator (unofficial)"
LABEL org.opencontainers.image.authors="code@soupbowl.io"
LABEL org.opencontainers.image.source="https://github.com/soup-bowl/opensimulator-docker"
LABEL org.opencontainers.image.licenses="MIT"

RUN apt-get update && apt-get install -y apt-utils libgdiplus libc6-dev libsqlite3-dev screen uuid-runtime

COPY --from=build /app /opt/opensim

COPY defaults  /opt/opensim/bin/defaults

EXPOSE 9000

WORKDIR /opt/opensim/bin

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "screen", "-S", "OpenSim", "-D", "-m", "sh",  "./opensim.sh" ]