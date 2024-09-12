# Docker image for Phoebus

## Usage

Default run command (standalone)
```bash
docker run --network host -e DISPLAY=$DISPLAY --device /dev/dri -v <LOCAL_DIR>:/config -v /tmp/.X11-unix:/tmp/.X11-unix paluma.ruhr-uni-bochum.de/epics/phoebus -settings <CONFIG_FILE>
```
On the host system a user with `UID=1000` has to exists with read/write access to the X server of the host system.

## Build
This image uses multistage build. In the first stage, phoebus is compiled, in the later stages the different modules are deployed.
Build with caching enabled (default) and using the `--target` option from docker build, each deploy-stage can be used to create an individual image without having to rebuild any of the previous stages.

```bash
docker build --pull [--push] [--build-arg ARG=VALUE]... --target ta_phoebus -t <REGISTRY>/phoebus:<TAG> .
docker build --pull [--push] [--build-arg ARG=VALUE]... --target ta_archive-engine -t <REGISTRY>/archive-engine:<TAG> .
```

## Docker Build Arguments

| Variable                 | Description                                             | Default value                        |
|--------------------------|---------------------------------------------------------|--------------------------------------|
| JDK_VERSION              | Tag of the openjdk base image                           | 24-slim-bookworm                     |
| PHOEBUS_DIR              | Install directory for Phoebus                           | /opt/phoebus                         |
| PHOEBUS_VERSION          | Version of the phoebus package to build                 |                                      |
| TZDATA                   | Used timezone                                           | Europe/Berlin                        |
