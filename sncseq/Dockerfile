ARG EPICS_BASE_IMG=paluma.ruhr-uni-bochum.de/epics/base \
    EPICS_BASE_VERSION=7.0.8.1

FROM ${EPICS_BASE_IMG}:${EPICS_BASE_VERSION}

ARG EPICS_MODULES=modules \
    SNCSEQ_VERSION=2-2-9 \
    IOCTEMPLATE_VERSION=1.2.0

RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    set -eux ; \
    apt-get update ; \
    apt-get install -qqy --no-install-recommends re2c ; \
    mkdir -p ${EPICS_TOP}/${EPICS_MODULES} ; \
    echo "EPICS_BASE = ${EPICS_TOP}/base" > ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local ; \
    ln -s ${EPICS_TOP}/${EPICS_MODULES}/RELEASE.local /src/RELEASE.local

ADD https://github.com/epics-modules/sequencer.git#R$SNCSEQ_VERSION /src/sequencer
ADD git@git.gsi.de:panda/pandadcs/ioc-template.git#v$IOCTEMPLATE_VERSION /src/ioc-template

RUN set -eux ; \
    echo "INSTALL_LOCATION = ${EPICS_TOP}/${EPICS_MODULES}/sncseq" > /src/sequencer/configure/CONFIG_SITE.local ; \
    sed -i -e '/^DIRS\s*+=\s*test/s/^/#/g' /src/sequencer/Makefile ; \
    sed -i -e '/^DIRS\s*+=\s*examples/s/^/#/g' /src/sequencer/Makefile ; \
    make -j $(nproc) -C /src/sequencer ; \
    echo "SNCSEQ = ${EPICS_TOP}/${EPICS_MODULES}/sncseq" >> /src/RELEASE.local ; \
    make -C /src/sequencer realclean ; \
    rm ${EPICS_TOP}/${EPICS_MODULES}/sncseq/configure/RULES_BUILD
## We need to delete $(INSTALL_LOCATION)/configure/RULES_BUILD from the sequencer as a hotfix for
## https://github.com/epics-modules/sequencer/issues/1
