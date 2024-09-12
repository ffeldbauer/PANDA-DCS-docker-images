ARG DEB_VERSION=bookworm-slim

FROM debian:${DEB_VERSION}
LABEL maintainer="Florian Feldbauer <florian@ep1.ruhr-uni-bochum.de> (@florian)"

ARG EPICS_TOP \
    EPICS_BASE_VERSION=7.0.8.1

ENV DEBIAN_FRONTEND=noninteractive \
    EPICS_TOP=${EPICS_TOP:-"/opt/epics"}

SHELL ["/bin/bash", "-c"]

RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    set -eux ; \
    apt-get update ; \
    apt-get install -qqy --no-install-recommends g++ make libreadline-dev perl patch ; \
    mkdir -p ${EPICS_TOP} ; \
    mkdir /src

ADD https://github.com/epics-base/epics-base.git#R${EPICS_BASE_VERSION} /src/epics-base

RUN set -eux ; \
    EPICS_HOST_ARCH=$(/src/epics-base/startup/EpicsHostArch) ; \
    if [[ "${EPICS_HOST_ARCH}" == "linux-aarch64" ]] && dpkg --compare-versions ${EPICS_BASE_VERSION} eq 7.0.6.1 ; then \
      sed -i -e "/COMMANDLINE_LIBRARY\s*=\s*READLINE$/s/^#//" \
          /src/epics-base/configure/os/CONFIG_SITE.Common.${EPICS_HOST_ARCH} ; \
    fi ; \
    sed -i -e '/^OPT_C[X]\{0,2\}FLAGS_YES\s*+=\s*-g/s/^/#/g' \
        /src/epics-base/configure/os/CONFIG_SITE.${EPICS_HOST_ARCH}.${EPICS_HOST_ARCH} ; \
    sed -i -e '/^DIRS\s*+=\s*test/s/^/#/g' \
        /src/epics-base/Makefile \
        /src/epics-base/modules/*/Makefile ; \
    echo "INSTALL_LOCATION = ${EPICS_TOP}/base" > /src/epics-base/configure/CONFIG_SITE.local ; \
    make -j $(nproc) -C /src/epics-base ; \
    make -C /src/epics-base realclean ; \
    { \
      echo "export EPICS_HOST_ARCH=${EPICS_HOST_ARCH}" ; \
      echo "export PATH=${EPICS_TOP}/base/bin/${EPICS_HOST_ARCH}\${PATH:+:\$PATH}" ; \
    } > /etc/profile.d/epics.sh
