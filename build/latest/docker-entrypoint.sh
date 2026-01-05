#!/usr/bin/env sh
set -e

chown -R "$(id -u):$(id -g)" defaults

if [ ! -e OpenSim.ini ]; then
    printf '%s\n' "INFO: No OpenSim configuration found, pulling one together." >&2
    cp defaults/OpenSim.ini OpenSim.ini

    if [ -n "${PHYSICS_ENGINE}" ]; then
        printf '\n[Startup]\nphysics = %s\n' "${PHYSICS_ENGINE:-BulletSim}" >> OpenSim.ini
    fi

    printf '\n[Estates]\nDefaultEstateName = %s\nDefaultEstateOwnerName = %s\nDefaultEstateOwnerUUID = %s\nDefaultEstateOwnerEMail = %s\nDefaultEstateOwnerPassword = %s\n' \
        "${ESTATE_NAME:-Default Estate}" \
        "${ESTATE_OWNER_NAME:-Foo Bar}" \
        "${ESTATE_OWNER_UUID:-00000000-0000-0000-0000-000000000000}" \
        "${ESTATE_OWNER_EMAIL:-user@example.com}" \
        "${ESTATE_OWNER_PASSWORD:-password}" >> OpenSim.ini

    if [ "${DATABASE_ENGINE}" = "mysql" ]; then
        printf '\n[Messaging]\nStorageProvider = "OpenSim.Data.MySQL.dll"\nConectionString = "Data Source=%s;Database=%s;User ID=%s;Password=%s;Old Guids=true;"\n' \
            "${MYSQL_SERVER:-db}" "${MYSQL_DATABASE:-opensim}" "${MYSQL_USER:-root}" "${MYSQL_PASSWORD}" >> OpenSim.ini
    fi
else
    printf '%s\n' "INFO: OpenSimulator general configuration found. Skipping..." >&2
fi

if [ ! -e config-include/StandaloneCommon.ini ] && [ ! -e config-include/GridCommon.ini ]; then
    printf '%s\n' "INFO: No Grid Common configuration found, pulling one together." >&2
    cp defaults/StandaloneCommon.ini config-include/StandaloneCommon.ini

    printf '\n[DatabaseService]\n' >> config-include/StandaloneCommon.ini
    if [ "${DATABASE_ENGINE}" = "mysql" ]; then
        printf '    StorageProvider = "OpenSim.Data.MySQL.dll"\n' >> config-include/StandaloneCommon.ini
        printf '    ConnectionString = "Data Source=%s;Database=%s;User ID=%s;Password=%s;Old Guids=true;"\n' \
            "${MYSQL_SERVER:-db}" "${MYSQL_DATABASE:-opensim}" "${MYSQL_USER:-root}" "${MYSQL_PASSWORD}" >> config-include/StandaloneCommon.ini
    else
        printf '    Include-Storage = "config-include/storage/SQLiteStandalone.ini"\n' >> config-include/StandaloneCommon.ini
    fi

    printf '\n[GridService]\n    StorageProvider = "OpenSim.Data.Null.dll:NullRegionData"\n    Region_%s = "DefaultRegion, FallbackRegion"\n    ExportSupported = true\n' \
        "${REGION_NAME:-Region}" >> config-include/StandaloneCommon.ini

    if [ -n "${GRID_WELCOME}" ]; then
        sed -i -e "s/OpenSimulator is running!/${GRID_WELCOME}/g" config-include/StandaloneCommon.ini
    fi

    if [ -n "${GRID_NAME}" ]; then
        sed -i -e "s/OpenSimulator Instance/${GRID_NAME}/g" config-include/StandaloneCommon.ini
    fi
else
    printf '%s\n' "INFO: Standalone or Grid configuration found. Skipping..." >&2
fi

if [ "$(find Regions -maxdepth 1 -name '*.ini' | wc -l)" -eq 0 ]; then
    printf '%s\n' "INFO: No region details found, pulling one together." >&2
    printf '\n[%s]\nRegionUUID = %s\nLocation = %s\nInternalAddress = 0.0.0.0\nInternalPort = 9000\nAllowAlternatePorts = False\nExternalHostName = %s\n' \
        "${REGION_NAME:-Region}" "$(uuidgen)" "${REGION_LOCATION:-1000,1000}" "${REGION_EXTERNAL_HOSTNAME:-localhost}" >> Regions/Regions.ini
else
    printf '%s\n' "INFO: Looks like there's region definitions. Skipping..." >&2
fi

if [ ! -e config-include/storage/SQLiteStandalone.ini ]; then
    cp defaults/SQLiteStandalone.ini config-include/storage/SQLiteStandalone.ini
    mkdir -p sqlite-database
fi

exec "$@"
