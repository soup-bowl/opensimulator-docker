#!/usr/bin/env bash
set -Eeuo pipefail

chown -R $(id -u):$(id -g) defaults

if [ ! -e OpenSim.ini ]; then
	echo >&2 "INFO: No OpenSim configuration found, pulling one together."
	cp defaults/OpenSim.ini OpenSim.ini
fi

if [ ! -e config-include/StandaloneCommon.ini ]; then
	echo >&2 "INFO: No Grid Common configuration found, pulling one together."
	cp defaults/StandaloneCommon.ini config-include/StandaloneCommon.ini
fi

if [ `find Regions -maxdepth 1 -name '*.ini' | wc -l` -eq 0 ]; then
	echo >&2 "INFO: No region details found, pulling one together."
	cp defaults/Regions.ini Regions/Regions.ini
fi 

exec "$@"
