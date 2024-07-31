#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

$ErrorActionPreference = "Stop"

if (-Not (Test-Path OpenSim.ini)) {
    Write-Host "INFO: No OpenSim configuration found, pulling one together."
    Copy-Item defaults/OpenSim.ini OpenSim.ini

    if ($env:PHYSICS_ENGINE) {
        Add-Content OpenSim.ini -Value "`n[Startup]`nphysics = $($env:PHYSICS_ENGINE)"
    }

    Add-Content OpenSim.ini -Value "`n[Estates]`nDefaultEstateName = $($env:ESTATE_NAME -or 'Default Estate')"
    Add-Content OpenSim.ini -Value "`nDefaultEstateOwnerName = $($env:ESTATE_OWNER_NAME -or 'Foo Bar')"
    Add-Content OpenSim.ini -Value "`nDefaultEstateOwnerUUID = $($env:ESTATE_OWNER_UUID -or '00000000-0000-0000-0000-000000000000')"
    Add-Content OpenSim.ini -Value "`nDefaultEstateOwnerEMail = $($env:ESTATE_OWNER_EMAIL -or 'user@example.com')"
    Add-Content OpenSim.ini -Value "`nDefaultEstateOwnerPassword = $($env:ESTATE_OWNER_PASSWORD -or 'password')"

    if ($env:DATABASE_ENGINE -eq "mysql") {
        Add-Content OpenSim.ini -Value "`n[Messaging]`nStorageProvider = `"OpenSim.Data.MySQL.dll`""
        Add-Content OpenSim.ini -Value "`nConnectionString = `"Data Source=$($env:MYSQL_SERVER -or 'db');Database=$($env:MYSQL_DATABASE -or 'opensim');User ID=$($env:MYSQL_USER -or 'root');Password=$($env:MYSQL_PASSWORD -or '');Old Guids=true;`""
    }
} else {
    Write-Host "INFO: OpenSimulator general configuration found. Skipping..."
}

if (-Not (Test-Path config-include/StandaloneCommon.ini) -and -Not (Test-Path config-include/GridCommon.ini)) {
    Write-Host "INFO: No Grid Common configuration found, pulling one together."
    Copy-Item defaults/StandaloneCommon.ini config-include/StandaloneCommon.ini

    Add-Content config-include/StandaloneCommon.ini -Value "[DatabaseService]"
    if ($env:DATABASE_ENGINE -eq "mysql") {
        Add-Content config-include/StandaloneCommon.ini -Value "    StorageProvider = `"OpenSim.Data.MySQL.dll`""
        Add-Content config-include/StandaloneCommon.ini -Value "    ConnectionString = `"Data Source=$($env:MYSQL_SERVER -or 'db');Database=$($env:MYSQL_DATABASE -or 'opensim');User ID=$($env:MYSQL_USER -or 'root');Password=$($env:MYSQL_PASSWORD -or '');Old Guids=true;`""
    } else {
        Add-Content config-include/StandaloneCommon.ini -Value "    Include-Storage = `"config-include/storage/SQLiteStandalone.ini`""
    }

    Add-Content config-include/StandaloneCommon.ini -Value "[GridService]"
    Add-Content config-include/StandaloneCommon.ini -Value "    StorageProvider = `"OpenSim.Data.Null.dll`:NullRegionData`""
    Add-Content config-include/StandaloneCommon.ini -Value "    Region_$($env:REGION_NAME -or 'Region') = `"DefaultRegion, FallbackRegion`""
    Add-Content config-include/StandaloneCommon.ini -Value "    ExportSupported = $true"

    if ($env:GRID_WELCOME) {
        (Get-Content config-include/StandaloneCommon.ini) -replace "OpenSimulator is running!", $env:GRID_WELCOME | Set-Content config-include/StandaloneCommon.ini
    }

    if ($env:GRID_NAME) {
        (Get-Content config-include/StandaloneCommon.ini) -replace "OpenSimulator Instance", $env:GRID_NAME | Set-Content config-include/StandaloneCommon.ini
    }
} else {
    Write-Host "INFO: Standalone or Grid configuration found. Skipping..."
}

if ((Get-ChildItem Regions -Filter '*.ini' | Measure-Object).Count -eq 0) {
    Write-Host "INFO: No region details found, pulling one together."

    $regionUUID = [guid]::NewGuid().ToString()
    Add-Content Regions/Regions.ini -Value "[${env:REGION_NAME -or 'Region'}]"
    Add-Content Regions/Regions.ini -Value "RegionUUID = $regionUUID"
    Add-Content Regions/Regions.ini -Value "Location = $($env:REGION_LOCATION -or '1000,1000')"
    Add-Content Regions/Regions.ini -Value "InternalAddress = 0.0.0.0"
    Add-Content Regions/Regions.ini -Value "InternalPort = 9000"
    Add-Content Regions/Regions.ini -Value "AllowAlternatePorts = $false"
    Add-Content Regions/Regions.ini -Value "ExternalHostName = $($env:REGION_EXTERNAL_HOSTNAME -or 'localhost')"
} else {
    Write-Host "INFO: Looks like there's region definitions. Skipping..."
}

if (-Not (Test-Path config-include/storage/SQLiteStandalone.ini)) {
    Copy-Item defaults/SQLiteStandalone.ini config-include/storage/SQLiteStandalone.ini
    New-Item -Path sqlite-database -ItemType Directory -Force
}

& $args
