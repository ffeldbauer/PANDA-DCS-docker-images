# Base image for EPICS base

This image is used as a base image for the [IOC](ioc/), [CA-Gateway](ca-gateway/), and [SNCSEQ](sncseq/) images

# Available tags @ paluma.ruhr-uni-bochum.de

| Digest       | Tags                 | Platforms    |
|--------------|----------------------|--------------|
| 7fa407064442 | 7.0.8.1 , 7 , latest | linux-amd64  |
| 9e7d64d3e85c | 7.0.8.1 , 7 , latest | linux-arm64  |
| 515cb1f1fc10 | 7.0.8.1 , 7 , latest | linux-arm/v7 |

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

