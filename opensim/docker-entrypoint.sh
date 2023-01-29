#!/usr/bin/env bash
set -Eeo pipefail

chown -R $(id -u):$(id -g) defaults

if [ ! -e OpenSim.ini ]; then
	echo >&2 "INFO: No OpenSim configuration found, pulling one together."
	cp defaults/OpenSim.ini OpenSim.ini
fi

if [ ! -e config-include/StandaloneCommon.ini ]; then
	echo >&2 "INFO: No Grid Common configuration found, pulling one together."
	cp defaults/StandaloneCommon.ini config-include/StandaloneCommon.ini

	echo "[DatabaseService]" >> config-include/StandaloneCommon.ini
	if [[ "${DATABASE_ENGINE}" == "mysql" ]]; then
		echo "    StorageProvider = \"OpenSim.Data.MySQL.dll\"" >> config-include/StandaloneCommon.ini
		echo "    ConnectionString = \"Data Source=${MYSQL_SERVER:-db};Database=${MYSQL_DATABASE:-opensim};User ID=${MYSQL_USER:-root};Password=${MYSQL_PASSWORD};Old Guids=true;\"" >> config-include/StandaloneCommon.ini
	else
		echo "    Include-Storage = \"config-include/storage/SQLiteStandalone.ini\"" >> config-include/StandaloneCommon.ini
	fi
	cat config-include/StandaloneCommon.ini
fi

if [ `find Regions -maxdepth 1 -name '*.ini' | wc -l` -eq 0 ]; then
	echo >&2 "INFO: No region details found, pulling one together."
	cp defaults/Regions.ini Regions/Regions.ini
fi 

exec "$@"
