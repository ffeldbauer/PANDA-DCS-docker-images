ARG EPICS_BASE_IMG=paluma.ruhr-uni-bochum.de/epics/base \
    EPICS_BASE_VERSION=7.0.8.1

FROM ${EPICS_BASE_IMG}:${EPICS_BASE_VERSION} AS builder

ARG EPICS_MODULES=modules \
    PCAS_VERSION=4.13.3 \
    CAGW_VERSION=2.1.3 \
    TZDATA="Europe/Berlin"

RUN set -eux ; \
    mkdir ${EPICS_TOP}/${EPICS_MODULES} ; \
    echo "EPICS_BASE = ${EPICS_TOP}/base" > ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    ln -s ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local /src/RELEASE.local

ADD https://github.com/epics-modules/pcas.git#v$PCAS_VERSION /src/pcas
RUN set -eux ; \
    echo "INSTALL_LOCATION = ${EPICS_TOP}/${EPICS_MODULES}/pcas" > /src/pcas/configure/CONFIG_SITE.local ; \
    make -j $(nproc) -C /src/pcas ; \
    echo "PCAS = ${EPICS_TOP}/${EPICS_MODULES}/pcas" >> /src/RELEASE.local ; \
    make -C /src/pcas realclean

ADD https://github.com/epics-extensions/ca-gateway.git#v$CAGW_VERSION /src/ca-gateway
RUN set -eux ; \
    echo "INSTALL_LOCATION = ${EPICS_TOP}/ca-gateway" > /src/ca-gateway/configure/CONFIG_SITE.local ; \
    make -j $(nproc) -C /src/ca-gateway ; \
    echo "export CAGW_EXE=\"${EPICS_TOP}/ca-gateway/bin/\${EPICS_HOST_ARCH}/gateway\"" >> /etc/profile.d/epics.sh ; \
    make -C /src/ca-gateway realclean

ADD --chmod=755 docker-cagw-entrypoint /usr/local/bin/

RUN set -eux ; \
    find ${EPICS_TOP} -name "*.a" -delete ; \
    apt-get purge --autoremove -qqy g++ make patch ; \
    rm -rf /src ; \
    useradd -m -g users -s /bin/bash epics ; \
    install -d -o epics -g users /config ; \
    rm -f /etc/timezone /etc/localtime ; \
    echo "$TZDATA" > /etc/timezone ; \
    ln -snf /usr/share/zoneinfo/${TZDATA} /etc/localtime

# Create new image from scratch and copy the complete filesystem from the original image to reduce the size of the image
FROM scratch
LABEL maintainer="Florian Feldbauer <florian@ep1.ruhr-uni-bochum.de> (@florian)"
COPY --from=builder  / /

USER epics
EXPOSE 5064 5064/udp
VOLUME ["/config"]
WORKDIR /config
ENTRYPOINT ["docker-cagw-entrypoint"]
CMD ["-help"]
