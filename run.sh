#!/bin/bash

echo -e "\x1B[7mContainer Name\x1B[27m"
read container

echo -e "\x1B[7mImage Name\x1B[27m"
read image

echo -e "\x1B[7mController Host\x1B[27m"
read controller_host

echo -e "\x1B[7mController Port\x1B[27m"
read controller_port

echo -e "\x1B[7mSSL enabled\x1B[27m"
read ssl_enabled

echo -e "\x1B[7mAccount Name\x1B[27m"
read account_name

echo -e "\x1B[7mAccess Key\x1B[27m"
read access_key

echo -e "\x1B[7mSIM enabled\x1B[27m"
read sim_enabled

echo -e "\x1B[7mDocker enabled\x1B[27m"
read docker_enabled

docker run -d --name $container \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /:/hostroot:ro \
    -v /tmp/app-agent:/opt/appdynamics/appagent/ \
    -e APPDYNAMICS_CONTROLLER_HOST_NAME="$controller_host" \
    -e APPDYNAMICS_CONTROLLER_PORT="$controller_port" \
    -e APPDYNAMICS_AGENT_ACCOUNT_NAME="$account_name" \
    -e APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="$access_key" \
    -e APPDYNAMICS_SIM_ENABLED="$sim_enabled" \
    -e APPDYNAMICS_CONTROLLER_SSL_ENABLED="$ssl_enabled" \
    -e APPDYNAMICS_DOCKER_ENABLED="$docker_enabled" \
    $image:latest

exit 0
