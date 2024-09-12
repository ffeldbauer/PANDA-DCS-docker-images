# Docker images for PANDA DCS

## Content
Docker images for the Detector Control System of the PANDA experiment

## Contributing
If you want to contribute to this repository, please read the [Contributing guide line](CONTRIBUTING.md).

## Build Requirements

- [Docker 19.03+](https://www.docker.com)
- [qemu](https://www.qemu.org/) (for multiplatform builds)

## Setting up docker buildx plugin for arm/v7 and arm64

`buildx` comes bundled with Docker CE starting with 19.03.
One can use it to cross-build images for different architectures. To cross-build images for `arm/v7` qmeu must be installed
and configured. Building an image for `arm/v7` using `buildx` takes way longer than using the Raspian base images from `balenalib`,
but this way the images can have the same tags for all architectures (and they can be shrinked using multistage builds).

### Using docker buildx under Debian 12

To enable the multi-platform build with `buildx` do the following
```bash
$ curl -fsSL https://download.docker.com/linux/debian/gpg -o /usr/share/keyrings/docker.asc
$ chmod a+r /usr/share/keyrings/docker.asc
$ echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.asc] https://download.docker.com/linux/debian" \
    "$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list
$ apt update
$ apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
$ apt update && apt install qemu-system-arm qemu-user-static binfmt-support
$ systemctl restart binfmt-support.service
$ docker buildx create --driver docker-container [--use] --name mybuilder
```

