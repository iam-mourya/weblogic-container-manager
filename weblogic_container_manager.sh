#!/bin/bash

# Starting WebLogic container management script...
echo "Starting WebLogic container management script..."

# Define the properties file location
properties_file="/home/ubuntu/domain.properties"

# Ensure domain.properties exists and has the correct username and password
if [ ! -f "$properties_file" ]; then
    echo "$properties_file not found. Creating it with admin-username and admin-password..."
    echo "admin-username=weblogic" > "$properties_file"
    echo "admin-password=weblogic@123" >> "$properties_file"
else
    echo "$properties_file already exists. No changes made."
fi

# Set permissions for domain.properties file (read/write for owner and group)
chmod 664 "$properties_file"
echo "Permissions for $properties_file set to 664."

# Checking for existing containers...
existing_container=$(docker ps -a -q -f "name=weblogic-container")
if [ ! -z "$existing_container" ]; then
    echo "Found existing WebLogic container(s). Removing them..."
    docker rm -f $existing_container
fi

# Running the WebLogic container with your original command
echo "Starting WebLogic container..."
docker run --privileged -d \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v $properties_file:/u01/oracle/properties/domain.properties \
  --name weblogic-container \
  -p 7001:7001 -p 7004:7004 -p 5556:5556 \
  container-registry.oracle.com/middleware/weblogic:12.2.1.4

# Waiting for the container to initialize...
echo "Waiting for the container to initialize..."
sleep 30

# Install procps and net-tools inside the WebLogic container
echo "Installing procps and net-tools in the WebLogic container..."
docker exec -u root -it weblogic-container yum install -y procps net-tools

# Finding config.xml inside the container...
container_id=$(docker ps -q -f "name=weblogic-container")
config_path="/u01/oracle/user_projects/domains/base_domain/config/config.xml"

echo "Found config.xml. Ensuring administration port is disabled..."

# Modify config.xml to disable the administration port (ensure it is set to 'false')
docker exec $container_id bash -c "sed -i 's/<administration-port-enabled>true<\/administration-port-enabled>/<administration-port-enabled>false<\/administration-port-enabled>/' $config_path"

# Verify if the modification was successful
docker exec $container_id bash -c "grep '<administration-port-enabled>false</administration-port-enabled>' $config_path"

# Ensure logs directory exists for NodeManager and AdminServer
docker exec $container_id bash -c "mkdir -p /u01/oracle/user_projects/domains/base_domain/logs"

# Start NodeManager
echo "Starting NodeManager inside the container..."
start_nodemanager="/u01/oracle/user_projects/domains/base_domain/bin/startNodeManager.sh"
docker exec $container_id bash -c "nohup $start_nodemanager > /u01/oracle/user_projects/domains/base_domain/logs/nodemanager.out 2>&1 &"

# Stop AdminServer by killing its process
echo "Stopping AdminServer by killing its process..."
docker exec $container_id bash -c "ps aux | grep '[w]eblogic.Server' | awk '{print \$2}' | xargs -I {} kill -9 {}"

# Restart the AdminServer
start_script="/u01/oracle/user_projects/domains/base_domain/bin/startWebLogic.sh"
echo "Starting AdminServer inside the container..."
docker exec $container_id bash -c "nohup $start_script > /u01/oracle/user_projects/domains/base_domain/logs/adminserver.out 2>&1 &"

# Wait for the AdminServer to come up
echo "Waiting for the AdminServer to come up..."
sleep 30

# Check the status of the Docker container
echo "Checking Docker container status..."
docker ps -a -f "name=weblogic-container"

# List running processes inside the container
echo "Listing running processes inside the container..."
docker exec $container_id ps -ef

# WebLogic container management completed.
echo "WebLogic container management completed."
