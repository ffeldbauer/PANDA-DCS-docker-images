#!/usr/bin/bash
set -e
JAR=$(ls ${PHOEBUS_DIR}/phoebus-product/target/product-*.jar | head -n1)
java -jar $JAR "$@"
