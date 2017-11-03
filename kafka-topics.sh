#!/usr/bin/env bash
# Load common configuration
. config.sh

docker run \
  --net host \
  --rm confluentinc/cp-kafka:3.3.0 \
  kafka-topics --zookeeper ${ZK_URLS} $@
