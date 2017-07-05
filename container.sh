#!/bin/bash

echo -e "\x1B[7mContainer Name\x1B[27m"
read container

docker run -d \
  --volumes-from app-agent \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume /dev:/dev \
  --volume /sys:/sys \
  --volume /var/log:/var/log \
  --privileged \
  --net=host \
  --pid=host \
  --name $container -d \
  -e APPDYNAMICS_AGENT_UNIQUE_HOST_ID="$HOSTNAME" \
  michi/appd-agents
