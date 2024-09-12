# Base Image for SNC Sequencer

This image is used as base image for building finite state machines

# Available tags @ paluma.ruhr-uni-bochum.de

| Digest       | Tags                 | Platforms    |
|--------------|----------------------|--------------|
| 7ff25cd202d7 | 2.2.9 , 2 , latest   | linux-amd64  |
| f5166e4c7078 | 2.2.9 , 2 , latest   | linux-arm64  |
| 3e3ebfa27185 | 2.2.9 , 2 , latest   | linux-arm/v7 |

# Build

```bash
docker build --pull [--platform=linux/amd64,linux/arm64,linux/arm/v7] [--push] [--build-arg ARG=VALUE]... -t <REGISTRY>/ioc:<TAG> .
```

## Docker Build Arguments

| Variable                 | Description                                             | Default value                        |
|--------------------------|---------------------------------------------------------|--------------------------------------|
| EPICS_BASE_IMG           | Name of the base image to use                           | paluma.ruhr-uni-bochum.de/epics/base |
| EPICS_BASE_VERSION       | Tag of the base image to use                            | 7.0.8.1                              |
| EPICS_MODULES            | Install path for modules relativ to EPICS_DIR           | modules/                             |
| SNCSEQ_VERSION           | Version of the SNCSEQ support module                    | 2-2-9                                |
| TZDATA                   | Used timezone                                           | Europe/Berlin                        |

