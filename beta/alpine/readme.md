# OpenSimulator Alpine Test

This is a test of the OpenSimulator Docker image [running on an Alpine base](https://hub.docker.com/_/alpine/).

## For Graduation

### Pass Verification

* :heavy_check_mark: - Able to build successfully.
* :x: - Able to run successfully like or close to the main build.
* :x: - Does not depend on beta/alpha packages.

### Steps for Pass

* :x: - Mono library leaves testing on the [Alpine package registry](https://pkgs.alpinelinux.org/package/edge/testing/x86_64/mono).
* :x: - Fatal error occurs when SQLite engine is used.
  - MySQL engine works fine.

```
=================================================================
        Native Crash Reporting
=================================================================
Got a SIGSEGV while executing native code. This usually indicates
a fatal error in the mono runtime or one of the native libraries 
used by your application.
=================================================================

=================================================================
        Basic Fault Address Reporting
=================================================================
instruction pointer is NULL, skip dumping
=================================================================
        Managed Stacktrace:
=================================================================
          at <unknown> <0xffffffff>
          at Mono.Data.SqliteClient.Sqlite:sqlite3_open16 <0x000b7>
          at Mono.Data.SqliteClient.SqliteConnection:Open <0x001e3>
          at OpenSim.Region.UserStatistics.WebStatsModule:PostInitialise <0x000ad>
          at OpenSim.ApplicationPlugins.RegionModulesController.RegionModulesControllerPlugin:PostInitialise <0x000c6>
          at OpenSim.OpenSimBase:StartupSpecific <0x00806>
          at OpenSim.OpenSim:StartupSpecific <0x00387>
          at OpenSim.Framework.Servers.BaseOpenSimServer:Startup <0x00212>
          at OpenSim.Application:Main <0x01078>
          at <Module>:runtime_invoke_void_object <0x00091>
=================================================================
```
