#!/usr/bin/env bash
# Load common configuration
. config.sh

if [ "$DEBUG" ]; then
  docker=echo
else
  docker=docker
fi

# Turn the ZK_HOSTS variable into an array for easier iteration
zk_hosts=($ZK_HOSTS)

for i in "${!zk_hosts[@]}"; do
  zk_id=$((i + 1))
  service_name="$ZK_SERVICE_PREFIX$zk_id"
  command="$docker service rm $service_name"
  echo "Stopping service $service_name:"
  echo "# $command"
  $command
  echo
done
