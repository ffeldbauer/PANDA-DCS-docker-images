ARG EPICS_BASE_IMG="paluma.ruhr-uni-bochum.de/epics/base" \
    EPICS_BASE_VERSION=7.0.8.1

FROM ${EPICS_BASE_IMG}:${EPICS_BASE_VERSION} AS builder

ARG EPICS_MODULES=modules \
    IOC_NAME=epicsIoc \
    IOC_TOP=ioc

RUN set -eux ; \
    mkdir -p ${EPICS_TOP}/${EPICS_MODULES} ; \
    { \
      echo "SUPPORT = ${EPICS_TOP}/${EPICS_MODULES}" ; \
      echo "undefine IPAC" ; \
      echo "undefine PCRE" ; \
      echo "undefine SNCSEQ" ; \
      echo "undefine SSCAN" ; \
      echo "EPICS_BASE = ${EPICS_TOP}/base" ; \
    } > ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    ln -s ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local /src/RELEASE.local

## We want each support module to be optional but Docker itself does not support IF-THEN-ELSE
## As a workaround we use parameter expansions for our arguments:
##
## For each module we define an argument for its version and an argument for its URL
##
## ARG MODULE_VERSION
## ARG MODULE_URL=${MODULE_VERSION:+https://...}
##
## => ${parameter:+word} : If parameter is null or unset, nothing is substituted, otherwise the expansion of word is substituted.
## => if the version argument is unsetor null, the URL argument will be null
## => if the version argument is set and not null, the URL argument will be set to the url of the source packages
##
## ADD ${MOUDLE_VERSION:-*.h} /src/module
##
## => ${parameter:-word} : If parameter is unset or null, the expansion of word is substituted. Otherwise, the value of parameter is substituted.
## => if URL is null, the argument given to ADD will be `*.h`.
##    using a wildcard  (`*.h`), ADD will always return successfull even if no files were found that match our pattern
## => if URL is not null, the actual value of this argument will be used as 1st argument for `ADD`

# ### EXECUTE ### #
ARG EXECUTE_VERSION \
    EXECUTE_URL=${EXECUTE_VERSION:+https://github.com/KIT-IBPT/epics-execute.git#v${EXECUTE_VERSION}}
ADD ${EXECUTE_URL:-*.h} /src/execute
RUN if [[ -z "$EXECUTE_VERSION" ]] ; then exit 0 ; fi ; \
    set -eux ; \
    echo 'INSTALL_LOCATION = $(SUPPORT)/execute' >> /src/execute/configure/CONFIG_SITE ; \
    make -j $(nproc) -C /src/execute; \
    echo 'EXECUTE = $(SUPPORT)/execute' >> ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    make -C /src/execute realclean

# ### IOCSTATS ### #
ARG IOCSTATS_VERSION \
    IOCSTATS_URL=${IOCSTATS_VERSION:+https://github.com/epics-modules/iocStats.git#${IOCSTATS_VERSION}}
ADD ${IOCSTATS_URL:-*.h} /src/iocstats
RUN if [[ -z "$IOCSTATS_VERSION" ]] ; then exit 0 ; fi ; \
    set -eux ; \
    echo "MAKE_TEST_IOC_APP = NO" > /src/iocstats/configure/RELEASE.local ; \
    echo 'INSTALL_LOCATION = $(SUPPORT)/iocstats' > /src/iocstats/configure/CONFIG_SITE.local ; \
    make -j $(nproc) -C /src/iocstats ; \
    echo 'DEVIOCSTATS = $(SUPPORT)/iocstats' >> ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    make -C /src/iocstats realclean

# ### AUTOSAVE ### #
ARG AUTOSAVE_VERSION \
    AUTOSAVE_URL=${AUTOSAVE_VERSION:+https://github.com/epics-modules/autosave.git#R${AUTOSAVE_VERSION}}
ADD ${AUTOSAVE_URL:-*.h} /src/autosave
RUN if [[ -z "$AUTOSAVE_VERSION" ]] ; then exit 0 ; fi ; \
    set -eux ; \
    echo 'INSTALL_LOCATION = $(SUPPORT)/autosave' > /src/autosave/configure/CONFIG_SITE.local ; \
    make -j $(nproc) -C /src/autosave; \
    echo 'AUTOSAVE = $(SUPPORT)/autosave' >> ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    make -C /src/autosave realclean

# ### DEVGPIO #### #
ARG DEVGPIO_VERSION \
    DEVGPIO_URL=${DEVGPIO_VERSION:+https://github.com/ffeldbauer/epics-devgpio.git#R${DEVGPIO_VERSION}}
ADD ${DEVGPIO_URL:-*.h} /src/devgpio
RUN if [[ -z "$DEVGPIO_VERSION" ]] ; then exit 0 ; fi ; \
    set -eux ; \
    echo 'INSTALL_LOCATION = $(SUPPORT)/devgpio' > /src/devgpio/configure/CONFIG_SITE.local ; \
    make -j $(nproc) -C /src/devgpio ; \
    echo 'DEVGPIO = $(SUPPORT)/devgpio' >> ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    make -C /src/devgpio realclean

# ### DEVTHMPLEDPULSER ### #
ARG DEVTHMPLEDPULSER_VERSION \
    DEVTHMPLEDPULSER_URL=${DEVTHMPLEDPULSER_VERSION:+git@git.gsi.de:panda/pandadcs/devthmpledpulser.git#v${DEVTHMPLEDPULSER_VERSION}}
ADD ${DEVTHMPLEDPULSER_URL:-*.h} /src/devThmpLedPulser
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    if [[ -z "$DEVTHMPLEDPULSER_VERSION" ]] ; then exit 0 ; fi ; \
    set -eux ; \
    apt-get update ; \
    apt-get install -qqy --no-install-recommends libsocketcan-dev python3 ; \
    echo 'INSTALL_LOCATION = $(SUPPORT)/devThmpLedPulser' > /src/devThmpLedPulser/configure/CONFIG_SITE.local ; \
    make -j $(nproc) -C /src/devThmpLedPulser ; \
    echo 'DEVTHMPLEDPULSER = $(SUPPORT)/devThmpLedPulser' >> ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    make -C /src/devThmpLedPulser realclean ; \
    apt-get purge --autoremove -qqy python3

# ### SNMP ### #
ARG SNMP_VERSION \
    SNMP_URL=${SNMP_VERSION:+https://groups.nscl.msu.edu/controls/files/epics-snmp-${SNMP_VERSION}.zip} \
    WIENER_MIB_VERSION=5704 \
    WIENER_MIB_URL=${SNMP_VERSION:+http://file.wiener-d.com/software/net-snmp/WIENER-CRATE-MIB-${WIENER_MIB_VERSION}.zip}
ADD ${SNMP_URL:-*.h} /src
ADD ${WIENER_MIB_URL:-*h} /src
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    if [[ -z "$SNMP_VERSION" ]] ; then exit 0 ; fi ; \
    set -eux ; \
    if (( $(. /etc/os-release && echo $VERSION_ID) >= 12 )) ; then \
      sed -i 's/^Components: main$/& non-free/' /etc/apt/sources.list.d/debian.sources ; \
    else \
      echo "deb http://deb.debian.org/debian $(. /etc/os-release && echo $CODENAME) non-free" > /etc/apt/sources.list.d/nonfree.list ; \
    fi ; \
    apt-get update ; \
    apt-get install -qqy --no-install-recommends libsnmp-dev unzip snmp-mibs-downloader ; \
    mkdir /src/snmp ; \
    unzip -d /src/snmp /src/epics-snmp-${SNMP_VERSION}.zip ; \
    . /etc/profile.d/epics.sh ; \
    echo '-include $(TOP)/../RELEASE.local' >> /src/snmp/configure/RELEASE ; \
    echo 'INSTALL_LOCATION_APP = $(SUPPORT)/snmp' > /src/snmp/configure/RELEASE.Common.${EPICS_HOST_ARCH} ; \
    make -j $(nproc) -C /src/snmp ; \
    echo 'SNMP = $(SUPPORT)/snmp' >> ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    download-mibs ; \
    unzip -p /src/WIENER-CRATE-MIB-${WIENER_MIB_VERSION}.zip WIENER-CRATE-MIB-${WIENER_MIB_VERSION}.txt > /usr/share/snmp/mibs/WIENER-CRATE-MIB.txt ; \
    make -C /src/snmp realclean ; \
    apt-get purge --autoremove -qqy unzip snmp-mibs-downloader

# ### CALC ### #
ARG CALC_VERSION \
    CALC_URL=${CALC_VERSION:+https://github.com/epics-modules/calc.git#R${CALC_VERSION}}
ADD ${CALC_URL:-*.h} /src/calc
RUN if [[ -z "$CALC_VERSION" ]] ; then \
      echo "undefine CALC" >> ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
      exit 0 ; \
    fi ; \
    set -eux ; \
    sed -i -e '/^DIRS\s*+=/ s/tests//g' /src/calc/Makefile ; \
    echo 'INSTALL_LOCATION = $(SUPPORT)/calc' > /src/calc/configure/CONFIG_SITE.local ; \
    make -j $(nproc) -C /src/calc ; \
    echo 'CALC = $(SUPPORT)/calc' >> ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    make -C /src/calc realclean

# ### ASYN ### #
ARG ASYN_VERSION \
    ASYN_URL=${ASYN_VERSION:+https://github.com/epics-modules/asyn.git#R${ASYN_VERSION}}
ADD ${ASYN_URL:-*.h} /src/asyn
RUN --mount=type=bind,source=patches,target=/src/patches,rw \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    if [[ -z "$ASYN_VERSION" ]] ; then exit 0 ; fi ; \
    set -eux ; \
    apt-get update ; \
    apt-get install -qqy --no-install-recommends libtirpc-dev ; \
    if dpkg --compare-versions ${ASYN_VERSION//-/.} eq 4.42 ; then \
      patch -d /src/asyn -p1 < /src/patches/asyn_selectableChunkSize_${ASYN_VERSION}.patch ; \
    fi ; \
    patch -d /src/asyn -p1 < /src/patches/asyn_do-not-build-tests.patch ; \
    { \
      echo 'INSTALL_LOCATION = $(SUPPORT)/asyn' ; \
      echo 'TIRPC = YES' ; \
    } > /src/asyn/configure/CONFIG_SITE.local ; \
    if dpkg --compare-versions ${ASYN_VERSION//-/.} ge 4.38 ; then \
      apt-get install -qqy --no-install-recommends libusb-dev libftdi1-dev ; \
      { \
        echo 'DRV_USBTMC = YES' ; \
        echo 'DRV_FTDI = YES' ; \
        echo 'DRV_FTDI_USE_LIBFTDI1 = YES' ; \
      } >> /src/asyn/configure/CONFIG_SITE.local ; \
    fi ; \
    make -j $(nproc) -C /src/asyn; \
    echo 'ASYN = $(SUPPORT)/asyn' >> ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    make -C /src/asyn realclean

# ### DRVASYNI2C ### #
ARG DRVASYNI2C_VERSION \
    DRVASYNI2C_URL=${DRVASYNI2C_VERSION:+https://github.com/ffeldbauer/drvAsynI2C.git#R${DRVASYNI2C_VERSION}}
ADD ${DRVASYNI2C_URL:-*.h} /src/drvasyni2c
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    if [[ -z "$DRVASYNI2C_VERSION" ]] ; then exit 0 ; fi ; \
    set -eux ; \
    apt-get update ; \
    apt-get install -qqy --no-install-recommends i2c-tools ; \
    echo 'INSTALL_LOCATION = $(SUPPORT)/drvasyni2c' > /src/drvasyni2c/configure/CONFIG_SITE.local ; \
    make -j $(nproc) -C /src/drvasyni2c ; \
    echo 'DRVASYNI2C = $(SUPPORT)/drvasyni2c' >> ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    make -C /src/drvasyni2c

# ### MODBUS ### #
ARG MODBUS_VERSION \
    MODBUS_URL=${MODBUS_VERSION:+https://github.com/epics-modules/modbus.git#R${MODBUS_VERSION}}
ADD ${MODBUS_URL:-*.h} /src/modbus
RUN if [[ -z "$MODBUS_VERSION" ]] ; then exit 0 ; fi ; \
    set -eux ; \
    echo 'INSTALL_LOCATION = $(SUPPORT)/modbus' > /src/modbus/configure/CONFIG_SITE.local ; \
    make -j $(nproc) -C /src/modbus ; \
    echo 'MODBUS = $(SUPPORT)/modbus' >> ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    make -C /src/modbus realclean

# ### STREAM ### #
ARG STREAM_VERSION \
    STREAM_URL=${STREAM_VERSION:+https://github.com/paulscherrerinstitute/StreamDevice.git#${STREAM_VERSION}}
ADD ${STREAM_URL:-*.h} /src/stream
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    if [[ -z "$STREAM_VERSION" ]] ; then exit 0 ; fi ; \
    set -eux ; \
    apt-get update ; \
    apt-get install -qqy --no-install-recommends libpcre3-dev ; \
    if [[ -n "$DRVASYNI2C_VERSION" ]] ; then \
      if dpkg --compare-versions ${STREAM_VERSION} ge 2.8.20 ; then \
        patch -d /src/stream -p1 < /src/drvasyni2c/streamDevice/stream_drvasyni2c_2.8.20.patch ; \
      elif dpkg --compare-versions ${STREAM_VERSION} ge 2.8.15 && dpkg --compare-versions ${STREAM_VERSION} le 2.8.19 ; then \
        patch -d /src/stream -p1 < /src/drvasyni2c/streamDevice/stream_drvasyni2c_2.8.15.patch ; \
      else \
        patch -d /src/stream -p1 < /src/drvasyni2c/streamDevice/stream_drvasyni2c_2.8.10.patch ; \
      fi ; \
    fi ; \
    if dpkg --compare-versions ${STREAM_VERSION} lt 2.8.22 ; then \
      { \
        echo 'INSTALL_LOCATION_APP = $(SUPPORT)/stream' ; \
        echo 'PCRE_INCLUDE = /usr/include' ; \
        echo "PCRE_LIB = $(find /usr/lib -name libpcre.so -printf "%h")" ; \
      } > /src/stream/configure/RELEASE.Common.${EPICS_HOST_ARCH} ; \
    else \
      { \
        echo 'INSTALL_LOCATION = $(SUPPORT)/stream' ; \
        echo "PCRE_LIB = $(find /usr/lib -name libpcre.so -printf "%h")" ; \
      } > /src/stream/configure/CONFIG_SITE.local ; \
    fi ; \
    make -j $(nproc) -C /src/stream ; \
    echo 'STREAM = $(SUPPORT)/stream' >> ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    make -C /src/stream realclean

# ### IOC ### #
ARG IOCTEMPLATE_VERSION=1.2.0
ADD git@git.gsi.de:panda/pandadcs/ioc-template.git#v$IOCTEMPLATE_VERSION /src/ioc-template
RUN set -eux ; \
    . /etc/profile.d/epics.sh ; \
    mkdir /src/ioc ; \
    cd /src/ioc ; \
    makeBaseApp.pl -u epics -T /src/ioc-template -t ioc $IOC_NAME ; \
    { \
      echo "INSTALL_LOCATION = ${EPICS_TOP}/${IOC_TOP}" ; \
      echo "GENVERSIONDEFAULT = v$IOCTEMPLATE_VERSION" ; \
    } > configure/CONFIG_SITE.local ; \
    make -j $(nproc) ; \
    { \
      echo "export IOC_EXE=\"${EPICS_TOP}/${IOC_TOP}/bin/\${EPICS_HOST_ARCH}/${IOC_NAME}\"" ; \
      echo "export STREAM_PROTOCOL_PATH=\"${EPICS_TOP}/${IOC_TOP}/db\"" ; \
      echo "export DB_FILE_PATH=\"${EPICS_TOP}/${IOC_TOP}/db\"" ; \
    } >> /etc/profile.d/epics.sh

ADD --chmod=755 docker-ioc-entrypoint /usr/local/bin/

# ### Clean up and configure timezone ### #
ARG TZDATA="Europe/Berlin"
RUN set -eux ; \
    apt-get purge --autoremove -qqy g++ make patch ; \
    find ${EPICS_TOP} -name "*.a" -delete ; \
    rm -rf /src ; \
    useradd -m -g users -G dialout -s /bin/bash epics ; \
    install -d -o epics -g users /config ; \
    rm -f /etc/timezone /etc/localtime ; \
    echo "$TZDATA" > /etc/timezone ; \
    ln -snf /usr/share/zoneinfo/${TZDATA} /etc/localtime

# Create new image from scratch and copy the complete filesystem from the original image to reduce the size of the image
FROM scratch
LABEL maintainer="Florian Feldbauer <florian@ep1.ruhr-uni-bochum.de> (@florian)"
COPY --from=builder / /

EXPOSE 5064 5064/udp 5075 5076/udp
USER epics
VOLUME ["/config"]
WORKDIR /config
ENTRYPOINT ["docker-ioc-entrypoint"]
CMD ["-D"]
