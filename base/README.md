# Base image for EPICS base

This image is used as a base image for the [IOC](ioc/), [CA-Gateway](ca-gateway/), and [SNCSEQ](sncseq/) images

# Build

```bash
docker build [--pull] [--platform=linux/amd64,linux/arm64,linux/arm/v7] [--push] [--build-arg ARG=VALUE]... -t <IMAGE_NAME>:<TAG> .
```

## Docker Build Arguments

| Variable           | Description                                             | Default value    |
|--------------------|---------------------------------------------------------|------------------|
| DEB_VERSION        | Tag of debian image to use for build                    | bookworm-slim    |
| EPICS_TOP          | Base dir for epics installation                         | /opt/epics       |
| EPICS_BASE_VERSION | Version of EPICS base to build                          | 7.0.8.1          |

