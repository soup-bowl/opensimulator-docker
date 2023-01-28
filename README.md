# OpenSimulator in Docker

Work in progress to contain the OpenSimulator server software in a Docker container.

**Not ready for general use.**

## Usage

**This is still experimental - thar be bugs!**

```bash
docker run -d \
  --name opensim \
  -p 9000:9000 \
  -p 9000:9000/udp \
  ghcr.io/soup-bowl/opensimulator-docker:edge
```
