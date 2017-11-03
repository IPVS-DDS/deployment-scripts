#!/usr/bin/env bash
# Zookeeper Configuration
# Prefix for Zookeeper Docker services
export ZK_SERVICE_PREFIX="zookeeper-"
# Hostnames or IPs of all Zookeeper instances, space separated. Hostnames must
# be defined in the /etc/hosts file on each of the cluster's nodes.
export ZK_HOSTS="dds-op-1 dds-op-2 dds-op-3"
export ZK_CLIENT_PORT=2181
export ZK_PORT=2888
export ZK_ELECTION_PORT=3888

# Kafka Configuration
export KAFKA_SERVICE_PREFIX="kafka-"
# Hostnames or IPs of all Kafka instances, space separated Hostnames must
# be defined in the /etc/hosts file on each of the cluster's nodes.
export KAFKA_HOSTS="dds-op-1 dds-op-2 dds-op-3"
export KAFKA_PORT=9092

# Automatically set values
## Kafka URL string and host list
kafka_urls=""
kafka_hostnames=($KAFKA_HOSTS)
for i in "${!kafka_hostnames[@]}"; do
  if [ $i -ne "0" ]; then
    kafka_urls="$kafka_urls,"
  fi
  kafka_urls="${kafka_urls}${kafka_hostnames[$i]}:$KAFKA_PORT"
done
export KAFKA_URLS="$kafka_urls"

## Zookeeper URL string and host list
zk_urls=""
zk_hostnames=($ZK_HOSTS)
for i in "${!zk_hostnames[@]}"; do
  if [ $i -ne "0" ]; then
    zk_urls="$zk_urls,"
  fi
  zk_urls="${zk_urls}${zk_hostnames[$i]}:$ZK_CLIENT_PORT"
done
export ZK_URLS="$zk_urls"
