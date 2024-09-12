ARG EPICS_SNCSEQ_IMG=paluma.ruhr-uni-bochum.de/epics/sncseq \
    EPICS_SNCSEQ_VERSION=2.2.9

FROM ${EPICS_SNCSEQ_IMG}:${EPICS_SNCSEQ_VERSION} AS builder

RUN set -eux ; \
    . /etc/profile.d/epics.sh ; \
    mkdir /src/fsm ; \
    cd /src/fsm ; \
    makeBaseApp.pl -u epics -T /src/ioc-template -t seq sncExample ; \
    echo 'INSTALL_LOCATION = ${EPICS_TOP}/sncExample' > configure/CONFIG_SITE.local

COPY sncExample.st /src/fsm/sncExampleApp/

RUN set -eux ; \
    make -j $(nproc) -C /src/fsm ; \
    echo "export FSM_EXE=\"${EPICS_TOP}/sncExample/bin/\${EPICS_HOST_ARCH}/sncExample\"" >> /etc/profile.d/epics.sh; \
    make -C /src/fsm realclean

ARG TZDATA="Europe/Berlin"
RUN set -eux ;\
    apt-get purge --autoremove -qqy g++ make patch ; \
    apt-get clean ; \
    find ${EPICS_TOP} -name "*.a" -delete ; \
    rm -rf /src ; \
    useradd -m -g users -s /bin/bash epics ; \
    install -d -o epics -g users /config ; \
    rm -f /etc/timezone /etc/localtime ; \
    echo "$TZDATA" > /etc/timezone ; \
    ln -snf /usr/share/zoneinfo/${TZDATA} /etc/localtime

COPY --chmod=755 docker-fsm-entrypoint /usr/local/bin/

#########################################################################################################################
# Create new image from scratch and copy the complete filesystem from the original image to reduce the size of the image
FROM scratch
LABEL maintainer="Florian Feldbauer <florian@ep1.ruhr-uni-bochum.de> (@florian)"
COPY --from=builder / /

USER epics
ENTRYPOINT ["docker-fsm-entrypoint"]
CMD ["-s"]
