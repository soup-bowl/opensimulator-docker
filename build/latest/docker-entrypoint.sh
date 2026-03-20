#!/usr/bin/env sh
set -eu

# Reads a Docker secret from /run/secrets/<name> if the _FILE variant is set.
# _FILE takes priority over the plain environment variable.
file_env() {
	var="$1"
	# Check it's a valid variable and not just a vibed-in donut.
	case "$var" in
		*[!A-Z0-9_]*) printf '%s\n' "ERROR: Invalid variable name passed to file_env: $var" >&2; exit 1 ;;
	esac
	file_var="${var}_FILE"
	eval val="\${$var:-}"
	eval file_val="\${$file_var:-}"

	if [ -n "$file_val" ]; then
		if [ -r "$file_val" ]; then
			val="$(cat "$file_val")"
		else
			printf '%s\n' "ERROR: Secret file '$file_val' (from ${file_var}) is not readable." >&2
			exit 1
		fi
	fi

	export "$var"="$val"
	unset "$file_var" 2>/dev/null || true
}

file_env MYSQL_PASSWORD
file_env ESTATE_OWNER_PASSWORD

chown -R "$(id -u):$(id -g)" defaults

if [ ! -e OpenSim.ini ]; then
	printf '%s\n' "INFO: No OpenSim configuration found, pulling one together." >&2
	cp defaults/OpenSim.ini OpenSim.ini

	if [ -n "${PHYSICS_ENGINE:-}" ]; then
		printf '\n[Startup]\nphysics = %s\n' "${PHYSICS_ENGINE:-BulletSim}" >> OpenSim.ini
	fi

	printf '\n[Estates]\n    DefaultEstateName = %s\n    DefaultEstateOwnerName = %s\n    DefaultEstateOwnerUUID = %s\n    DefaultEstateOwnerEMail = %s\n    DefaultEstateOwnerPassword = %s\n' \
		"${ESTATE_NAME:-Default Estate}" \
		"${ESTATE_OWNER_NAME:-Foo Bar}" \
		"${ESTATE_OWNER_UUID:-00000000-0000-0000-0000-000000000000}" \
		"${ESTATE_OWNER_EMAIL:-user@example.com}" \
		"${ESTATE_OWNER_PASSWORD:-password}" >> OpenSim.ini

	if [ "${DATABASE_ENGINE:-}" = "mysql" ]; then
		printf '\n[Messaging]\n    StorageProvider = "OpenSim.Data.MySQL.dll"\n    ConectionString = "Data Source=%s;Database=%s;User ID=%s;Password=%s;Old Guids=true;"\n' \
			"${MYSQL_SERVER:-db}" "${MYSQL_DATABASE:-opensim}" "${MYSQL_USER:-root}" "${MYSQL_PASSWORD:-}" >> OpenSim.ini
	fi
else
	printf '%s\n' "INFO: OpenSimulator general configuration found. Skipping..." >&2
fi

if [ ! -e config-include/StandaloneCommon.ini ] && [ ! -e config-include/GridCommon.ini ]; then
	printf '%s\n' "INFO: No Grid Common configuration found, pulling one together." >&2
	cp defaults/StandaloneCommon.ini config-include/StandaloneCommon.ini

	printf '[DatabaseService]\n' >> config-include/StandaloneCommon.ini
	if [ "${DATABASE_ENGINE:-}" = "mysql" ]; then
		printf '    StorageProvider = "OpenSim.Data.MySQL.dll"\n' >> config-include/StandaloneCommon.ini
		printf '    ConnectionString = "Data Source=%s;Database=%s;User ID=%s;Password=%s;Old Guids=true;"\n' \
			"${MYSQL_SERVER:-db}" "${MYSQL_DATABASE:-opensim}" "${MYSQL_USER:-root}" "${MYSQL_PASSWORD:-}" >> config-include/StandaloneCommon.ini
	else
		printf '    Include-Storage = "config-include/storage/SQLiteStandalone.ini"\n' >> config-include/StandaloneCommon.ini
	fi

	printf '\n[GridService]\n    StorageProvider = "OpenSim.Data.Null.dll:NullRegionData"\n    Region_%s = "DefaultRegion, FallbackRegion"\n    ExportSupported = true\n' "${REGION_NAME:-Region}" >> config-include/StandaloneCommon.ini

	if [ -n "${GRID_WELCOME:-}" ]; then
		sed -i -e "s/OpenSimulator is running!/${GRID_WELCOME}/g" config-include/StandaloneCommon.ini
	fi

	if [ -n "${GRID_NAME:-}" ]; then
		sed -i -e "s/OpenSimulator Instance/${GRID_NAME}/g" config-include/StandaloneCommon.ini
	fi
else
	printf '%s\n' "INFO: Standalone or Grid configuration found. Skipping..." >&2
fi

count="$(find Regions -maxdepth 1 -name '*.ini' 2>/dev/null | wc -l)"
if [ "${count}" -eq 0 ]; then
	printf '%s\n' "INFO: No region details found, pulling one together." >&2

	printf '\n[%s]\n\tRegionUUID = %s\n\tLocation = %s\n\tInternalAddress = 0.0.0.0\n    InternalPort = 9000\n    AllowAlternatePorts = False\n    ExternalHostName = %s\n' \
		"${REGION_NAME:-Region}" "$(uuidgen)" "${REGION_LOCATION:-1000,1000}" "${REGION_EXTERNAL_HOSTNAME:-localhost}" >> Regions/Regions.ini
else
	printf '%s\n' "INFO: Looks like there's region definitions. Skipping..." >&2
fi

if [ ! -e config-include/storage/SQLiteStandalone.ini ]; then
	cp defaults/SQLiteStandalone.ini config-include/storage/SQLiteStandalone.ini
	mkdir -p sqlite-database
fi

exec "$@"
