<h1 align="center">OpenSimulator</h1>

<p align="center">
  <a href="https://github.com/soup-bowl/opensimulator-docker/actions/workflows/build-main.yml"><img src="https://img.shields.io/github/actions/workflow/status/soup-bowl/opensimulator-docker/build-main.yml?style=plastic" alt="GitHub Workflow Status" /></a>
  <a href="https://hub.docker.com/r/soupbowl/opensimulator"><img src="https://img.shields.io/docker/image-size/soupbowl/opensimulator/latest?logo=docker&logoColor=white&style=plastic" alt="Docker Image Size (tag)" /></a>
  <a href="https://hub.docker.com/r/soupbowl/opensimulator"><img src="https://img.shields.io/docker/pulls/soupbowl/opensimulator?logo=docker&logoColor=white&style=plastic" alt="Docker Pulls" /></a>
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/11209477/215610935-abf2a083-5707-45e4-a8e4-468a43283c8a.png" alt="Screenshot from inside the Firestorm Metaverse client, showing a woman with a floating nametag 'foo bar' staring out into the ocean, standing upon a small mound island" />
</p>

From the [OpenSimulator][os] site:

> OpenSimulator is an open source multi-platform, multi-user 3D application server. It can be used to create a virtual environment (or world) which can be accessed through a variety of clients, on multiple protocols.

This **unofficial** Docker configuration aims to assist in setting the server up for testing and general purpose use.

**This is still experimental - thar be bugs!**

# Usage

```bash
docker run -d --name opensim -p 9000:9000 -p 9000:9000/udp soupbowl/opensimulator:latest
```

You can change settings with the following optional environmental overrides:

* `-e GRID_NAME=...` to define the name of [your grid][grid].
* `-e GRID_WELCOME=...` to show a custom message on the login screen.
* `-e REGION_NAME=...` to define the [Region][region] name.
* `-e ESTATE_NAME=...` to define the [Estate][estate] name.
* `-e ESTATE_OWNER_NAME=...` to set the estate owner name (and creates a login) - format of 'Firstname Lastname'.
* `-e ESTATE_OWNER_PASSWORD=...` to define a login password.
* `-e ESTATE_OWNER_UUID=...` for a custom UUID, if desired.
* `-e ESTATE_OWNER_EMAIL=...` to define the estate email address.
* `-e DATABASE_ENGINE=...` to change the database engine (sqlite and mysql support so far) - defaults to sqlite.
* `-e MYSQL_SERVER=...`, `-e MYSQL_DATABASE=...`, `-e MYSQL_USER=...`, `-e MYSQL_PASSWORD=...` if `DATABASE_ENGINE` is `mysql`.

Once the server is running, you should be able to connect to it on `localhost:9000`. In **Firestorm Viewer**, you can go to **Preferences**, then **Opensim**, then under **add new grid** put `localhost:9000` and you can then login.

If you don't define otherwise in the environments or a custom configuration, the login username is **Foo bar** and the password is **password**.

## SQLite Persistence

Outside of configurations, pretty much everything OpenSimulator does is stored in your chosen database provider. If you choose to leave the default on (sqlite), then your installation will not persist if you remove your container.

To aid the use of SQLite mode with persistent data, the default configuration has been modified to create the database directories into a dedicated directory (`/opt/opensim/bin/sqlite-database`). The following command will allow you to run a persistent SQLite setup.

(Note that if you use a custom `SQLiteStandalone.ini` file, this will not happen).

```
docker run -d --name opensim -p 9000:9000 -p 9000:9000/udp -v /path/on/your/system:/opt/opensim/bin/sqlite-database  soupbowl/opensimulator:latest
```

# Limitations

## Running Server Admin Commands

At current, there doesn't appear to be an implemented and/or documented approach to managing the server from _outside_ the active TTY, and running `docker attach opensim` seems to produce a blank prompt. You can `exec` into the container or edit the bound configuration script and restart the server to make changes, but in some server instances you might need to intercept the prompt.

Until a better solution is made, you can get crafty with `screen` to get access to the current prompt in terminal, with the caveat that logging will no longer work.

You can achieve this with a **Dockerfile** like so:

```dockerfile
FROM soupbowl/opensimulator:latest
CMD [ "screen", "-S", "OpenSim", "-D", "-m", "mono",  "./OpenSim.exe" ]
```

With a container running the above Dockerfile, you can access a controllable OpenSimulator administration prompt by running:

```
docker exec -it <container name> screen -r -d OpenSim
```

You can leave the screen session by pressing `ctrl + a` then `d`.

## Physics in ARM

Each image has an ARM64 architecture build. Your mileage may vary with these as the server environment was not designed for use outside x86_64.

Currently, **Physics environments do not appear to be natively supported**, and running a server with BulletSim or OpenDynamicsEngine (ODE) will cause a fatal exception. You unfortunately currently have to run the server without physics. This can be achieved with the following OpenSim configuration:

```ini
[Startup]
   physics = basicphysics
```

Alternatively, a suitable drop-in library in `lib64/libBulletSim-aarch64.so` for BulletSim Physics could work, but may be unsupported.

# Examples

See [this repository](https://github.com/soup-bowl/opensim-sandbox) for some example usages of this image.

# Variants

Variant names are listed in Dockerhub format. They are also available from the GitHub Registry, replacing `soupbowl/opensimulator` with `ghcr.io/soup-bowl/opensimulator-docker`.

## `soupbowl/opensimulator:latest`

The latest OpenSimulator image build using `mono:latest` as the build reference.

## `soupbowl/opensimulator:alpine-beta`

A bleeding edge variant using **Alpine** as the build image with **Mono** dependency added. Mono is currently not in the stable packages build, so this image is considered unstable. Progress can be tracked on the [#1 ticket](https://github.com/soup-bowl/opensimulator-docker/issues/1).

# Source Code

The source code of the Docker image is [found on the GitHub repository][src]. You can find the [OpenSimulator server software source code on their website](http://opensimulator.org/wiki/Developer_Documentation#Source_Code_Repository_Access).

[src]: https://github.com/soup-bowl/opensimulator-docker
[os]: http://opensimulator.org/wiki/Main_Page
[grid]: https://wiki.secondlife.com/wiki/Land#Grid
[estate]: https://wiki.secondlife.com/wiki/Land#Estate
[region]: https://wiki.secondlife.com/wiki/Land#Region
