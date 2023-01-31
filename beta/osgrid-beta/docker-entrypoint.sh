#!/usr/bin/env bash
set -Eeo pipefail

chown -R $(id -u):$(id -g) defaults

if [ ! -e OpenSim.ini ]; then
	echo >&2 "INFO: No OpenSim configuration found, pulling one together."
	cp defaults/OpenSim.ini OpenSim.ini

	echo -e "\n[Estates]
    DefaultEstateName = ${ESTATE_NAME:-Default Estate}
    DefaultEstateOwnerName = ${ESTATE_OWNER_NAME:-Foo Bar}
    DefaultEstateOwnerUUID = ${ESTATE_OWNER_UUID:-00000000-0000-0000-0000-000000000000}
    DefaultEstateOwnerEMail = ${ESTATE_OWNER_EMAIL:-user@example.com}
    DefaultEstateOwnerPassword = ${ESTATE_OWNER_PASSWORD:-password}" >> OpenSim.ini

	if [[ "${DATABASE_ENGINE}" == "mysql" ]]; then
		echo -e "\n[Messaging]
    StorageProvider = \"OpenSim.Data.MySQL.dll\"
    ConectionString = \"Data Source=${MYSQL_SERVER:-db};Database=${MYSQL_DATABASE:-opensim};User ID=${MYSQL_USER:-root};Password=${MYSQL_PASSWORD};Old Guids=true;\""  >> OpenSim.ini
	fi
fi

if [ ! -e config-include/GridCommon.ini ]; then
	echo >&2 "INFO: No Grid Common configuration found, pulling one together."
	cp defaults/GridCommon.ini config-include/GridCommon.ini

	echo "[DatabaseService]" >> config-include/GridCommon.ini
	if [[ "${DATABASE_ENGINE}" == "mysql" ]]; then
		echo "    StorageProvider = \"OpenSim.Data.MySQL.dll\"" >> config-include/GridCommon.ini
		echo "    ConnectionString = \"Data Source=${MYSQL_SERVER:-db};Database=${MYSQL_DATABASE:-opensim};User ID=${MYSQL_USER:-root};Password=${MYSQL_PASSWORD};Old Guids=true;\"" >> config-include/GridCommon.ini
	else
		echo "    Include-Storage = \"config-include/storage/SQLiteStandalone.ini\"" >> config-include/GridCommon.ini
	fi

	echo "[GridService]
    StorageProvider = \"OpenSim.Data.Null.dll:NullRegionData\"
    Region_${REGION_NAME:-Region} = \"DefaultRegion, FallbackRegion\"
    ExportSupported = true" >> config-include/GridCommon.ini

	if [ -n "${GRID_WELCOME}" ]; then
		sed -i -e "s/OpenSimulator is running!/${GRID_WELCOME}/g" config-include/GridCommon.ini
	fi

	if [ -n "${GRID_NAME}" ]; then
		sed -i -e "s/OpenSimulator Instance/${GRID_NAME}/g" config-include/GridCommon.ini
	fi
fi

if [ `find Regions -maxdepth 1 -name '*.ini' | wc -l` -eq 0 ]; then
	echo >&2 "INFO: No region details found, pulling one together."

	echo "[${REGION_NAME:-Region}]
	RegionUUID = $(uuidgen)
	Location = ${REGION_LOCATION}
	InternalAddress = 0.0.0.0
    InternalPort = 9000
    AllowAlternatePorts = False
    ExternalHostName = ${REGION_HOSTNAME}" >> Regions/Regions.ini
fi

if [ ! -e config-include/storage/SQLiteStandalone.ini ]; then
	cp defaults/SQLiteStandalone.ini config-include/storage/SQLiteStandalone.ini
	mkdir -p sqlite-database
fi

exec "$@"
