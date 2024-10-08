# Base Image for SNC Sequencer

This image is used as base image for building finite state machines

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

