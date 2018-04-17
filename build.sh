#!/bin/bash

echo -e "\x1B[7mMachine Agent Version\x1B[27m"
read machine_agent_version

echo -e "\x1B[7mJava Agent Version\x1B[27m"
read app_agent_version

echo -e "\x1B[7mImage Name\x1B[27m"
read image

cd docker

docker build \
--build-arg BASEURL=https://packages.appdynamics.com \
--build-arg MACHINE_AGENT_VERSION=$machine_agent_version \
--build-arg APP_AGENT_VERSION=$app_agent_version \
-t $image:latest .

exit 0
