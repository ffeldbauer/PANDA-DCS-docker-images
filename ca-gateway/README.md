# Image for the CA-Gateway

This image uses epics-base as base image to be build

# Available tags @ paluma.ruhr-uni-bochum.de

| Digest       | Tags                 | Platforms    |
|--------------|----------------------|--------------|
| 32b8bc9b236b | 2.1.3 , 2 , latest   | linux-amd64  |
| a5fe4af437cd | 2.1.3 , 2 , latest   | linux-arm64  |
| 9d0dd30a6cf9 | 2.1.3 , 2 , latest   | linux-arm/v7 |

# How to use this image

## Start a ca-gateway instance

The Channel Access gateway requires configuration files to work.
Refer to the [Gateway Users Guide](https://epics.anl.gov/EpicsDocumentation/ExtensionsManuals/Gateway/Gateway.html) for information on how to configure the gateway.

If `/my/custom/my.access` and `/my/custom/my.pvlist` are the path and names of your configuration files, you can start the gateway container like this:
```bash
$ docker run --name some-gw -v /my/custom:/config -d paluma.ruhr-uni-bochum.de/epics/ca-gateway:tag -cip clientip -sip serverip -pvlist my.pvlist -access my.access
```
... where `some-gw` is the name you want to assign to your container, `tag` is the tag specifying the ca-gateway version you want, and serverip/clientip are the ip addresses of the interface used for the CA client and CA server side of the gateway, respectively.

## Build

```bash
docker build --pull [--platform=linux/amd64,linux/arm64,linux/arm/v7] [--push] --build-arg PCAS_VERSION=<VERSION> --build-arg CAGW_VERSION=<VERSION> -t <REGISTRY>/base:<TAG> .
```

## Docker Build Arguments

| Variable                 | Description                                             | Default value                        |
|--------------------------|---------------------------------------------------------|--------------------------------------|
| EPICS_BASE_IMG           | Name of the base image to use                           | paluma.ruhr-uni-bochum.de/epics/base |
| EPICS_BASE_VERSION       | Tag of the base image to use                            | 7.0.8.1                              |
| EPICS_MODULES            | Install path for modules relativ to EPICS_DIR           | modules/                             |
| PCAS_VERSION             | Version of the PCAS support module                      | 4.13.3                               |
| CAGW_VERSION             | Version of the CA Gateway                               | 2.1.3                                |

