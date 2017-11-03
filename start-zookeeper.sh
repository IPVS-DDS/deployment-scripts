#!/usr/bin/env bash
# User configuration
image_name="confluentinc/cp-zookeeper:3.3.0"

# Load common configuration
. config.sh

if [ "$DEBUG" ]; then
  docker=echo
else
  docker=docker
fi

# Turn the ZK_HOSTS variable into an array for easier iteration
zk_hosts=($ZK_HOSTS)

zk_service_params=(
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
  # Set the port Zookeeper should listen on
  --env "ZOOKEEPER_CLIENT_PORT=$ZK_CLIENT_PORT"
)

# Build and add the servers list to the environment variables
zk_servers=""
for i in "${!zk_hosts[@]}"; do
  host=${zk_hosts[$i]}
  if [ "$i" -ne 0 ]; then
    zk_servers="$zk_servers;"
  fi
  zk_servers="${zk_servers}$host:$ZK_PORT:$ZK_ELECTION_PORT"
done
zk_service_params+=(--env "ZOOKEEPER_SERVERS=$zk_servers")

# Add instance-specific configuration and create one service per instance
for i in "${!zk_hosts[@]}"; do
  host="${zk_hosts[$i]}"
  zk_id=$((i + 1))
  # Add remaining service parameters
  service_params=(${zk_service_params[@]})
  service_name="$ZK_SERVICE_PREFIX$zk_id"
  service_params+=(
    # The name of the service
    --name "$service_name"
    # Constrain the service to only run on the node with the given hostname
    --constraint "node.hostname==$host"
    # The server ID of the service
    --env "ZOOKEEPER_SERVER_ID=$zk_id"
  )

  # Create the service
  command="$docker ${service_params[@]} $image_name"
  echo "Creating service $service_name:"
  echo "# $command"
  $command
  echo
done
