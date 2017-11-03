#!/usr/bin/env bash
# Load common configuration
. config.sh

if [ "$DEBUG" ]; then
  docker=echo
else
  docker=docker
fi

# Turn the KAFKA_HOSTS variable into an array for easier iteration
kafka_hosts=($KAFKA_HOSTS)

for i in "${!kafka_hosts[@]}"; do
  kafka_id=$((i + 1))
  service_name="$KAFKA_SERVICE_PREFIX$kafka_id"
  command="$docker service rm $service_name"
  echo "Stopping service $service_name:"
  echo "# $command"
  $command
  echo
done
