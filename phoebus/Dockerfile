ARG JDK_VERSION=24-slim-bookworm

FROM openjdk:$JDK_VERSION AS builder

SHELL ["/bin/bash", "-c"]

ARG PHOEBUS_DIR \
    PHOEBUS_VERSION=4.7.3 \
    TZDATA="Europe/Berlin"

ENV PHOEBUS_DIR=${PHOEBUS_DIR:-"/opt/phoebus"} \
    DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    set -eux ; \
    if [[ ! -d /usr/share/man/man1 ]] ; then mkdir -p /usr/share/man/man1 ; fi ; \
    apt-get update ; \
    apt-get install -qqy --no-install-recommends maven rsync ; \
    useradd -m -g users -G video -s /bin/bash epics ; \
    install -d -o epics -g users /config ; \
    mkdir -p $PHOEBUS_DIR

ADD https://github.com/ControlSystemStudio/phoebus.git#v$PHOEBUS_VERSION /src

RUN set -eux ; \
    cd /src ; \
    mvn clean verify -f dependencies/pom.xml ; \
    mvn -DskipTests clean install

RUN set -eux ; \
    rsync --archive --relative --prune-empty-dirs \
      --exclude 'maven-*' \
      --exclude 'test-*' \
      --exclude '*.tar.gz' \
      --exclude '*.zip' \
      --exclude '*.jar.original' \
      /src/services/./*/target ${PHOEBUS_DIR}/. ; \
    rsync --archive --relative --prune-empty-dirs \
      --exclude 'maven-*' \
      --exclude 'test-*' \
      --exclude '*.tar.gz' \
      --exclude '*.zip' \
      --exclude '*.jar.original' \
      /src/phoebus-product/target ${PHOEBUS_DIR}/. ; \
    rm -rf /src ; \
    apt-get purge --autoremove -qqy maven rsync ; \
    rm -f /etc/timezone /etc/localtime ; \
    echo "$TZDATA" > /etc/timezone ; \
    ln -snf /usr/share/zoneinfo/${TZDATA} /etc/localtime

##################################################################################################
## Deploy Phoebus

FROM builder AS pre_phoebus

RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    set -eux ; \
    apt-get install -qqy --no-install-recommends libx11-6 libgl1-mesa-glx libgl1-mesa-dri gir1.2-gtk-3.0 libxtst6 ; \
    find ${PHOEBUS_DIR} -mindepth 1 -maxdepth 1 -name phoebus-product -prune -o -exec rm -rf {} +

COPY phoebus.sh docker-phoebus-entrypoint /usr/local/bin/

FROM scratch AS ta_phoebus
COPY --from=pre_phoebus / /
USER epics
WORKDIR /config
VOLUME ["/config"]
EXPOSE 4918 8080
ENTRYPOINT ["docker-phoebus-entrypoint"]
CMD ["phoebus"]

##################################################################################################
## Deploy archive engine

FROM builder AS pre_archive-engine

RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    set -eux ; \
    apt-get install -qqy --no-install-recommends mariadb-client postgresql-client ; \
    find ${PHOEBUS_DIR} -mindepth 1 -maxdepth 1 -name archive-engine  -prune -o -exec rm -rf {} + ; \
    touch ${PHOEBUS_DIR}/FIRST_RUN ; \
    chown epics:users ${PHOEBUS_DIR}/FIRST_RUN

COPY archive-engine.sh docker-archiver-entrypoint /usr/local/bin/

FROM scratch AS ta_archive-engine
COPY --from=pre_archive-engine / /
USER epics
WORKDIR /config
VOLUME ["/config"]
EXPOSE 4812
ENTRYPOINT ["docker-archiver-entrypoint"]
CMD ["archive-engine.sh"]

