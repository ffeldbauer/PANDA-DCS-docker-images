#!/usr/bin/bash
set -e
JAR=$(ls ${PHOEBUS_DIR}/archive-engine/target/service-archive-engine-*.jar | head -n1)
java -jar $JAR "$@"
