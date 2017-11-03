#!/usr/bin/env bash
# User configuration
default_topic_replication_factor=3
image_name="confluentinc/cp-kafka:3.3.0"

# Uncomment to activate JMX metrics reporting
jmx_enabled=yes

# Load common configuration
. config.sh

if [ "$DEBUG" ]; then
  docker=echo
else
  docker=docker
fi

# Turn the KAFKA_HOSTS variable into an array for easier iteration
kafka_hosts=($KAFKA_HOSTS)

# Calculate actual replication factor (must not be more than the number of Kafka instances
kafka_hostcount=${#kafka_hosts[@]}
topic_replication_factor=$(($kafka_hostcount<$default_topic_replication_factor?$kafka_hostcount:$default_topic_replication_factor))

kafka_service_params=(
  # Instruct the docker command to create a new service
  service create
  # Wait until the service has settled until continuing
  --detach=false
  # Use the host's network instead of the virtual networks provided by Docker
  --network host
  # Restart the service if it fails
  --restart-condition on-failure
  # Try to restart the service up to three times in a row
  --restart-max-attempts 3
  # Zookeeper URLs for Kafka to connect to
  --env "KAFKA_ZOOKEEPER_CONNECT=$ZK_URLS"
  # Default replication factor for implicitly created topics
  --env "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=$topic_replication_factor"
)

if [ "$jmx_enabled" == "yes" ]; then
  kafka_service_params+=(--env "KAFKA_JMX_PORT=9999")
fi

# Add instance-specific configuration and create one service per instance
for i in "${!kafka_hosts[@]}"; do
  host="${kafka_hosts[$i]}"
  kafka_id=$((i + 1))
  # Add remaining service parameters
  service_params=(${kafka_service_params[@]})
  service_name="$KAFKA_SERVICE_PREFIX$kafka_id"
  service_params+=(
    # The name of the service
    --name "$service_name"
    # Constrain the service to only run on the node with the given hostname
    --constraint "node.hostname==$host"
    # The server ID of the service
    --env "KAFKA_BROKER_ID=$kafka_id"
    # Where the instance should to listen for connections
    --env "KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://$host:$KAFKA_PORT"
  )

  if [ "$jmx_enabled" == "yes" ]; then
    service_params+=(--env "KAFKA_JMX_HOSTNAME=$host")
  fi

  # Create the service
  command="$docker ${service_params[@]} $image_name"
  echo "Creating service $service_name:"
  echo "# $command"
  $command
  echo
done
