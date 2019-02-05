#!/bin/bash

echo -e "\x1B[7mMachine Agent Version\x1B[27m"
read machine_agent_version

echo -e "\x1B[7mJava Agent Version\x1B[27m"
read java_agent_version

echo -e "\x1B[7mImage Name\x1B[27m"
read image

echo -e "\x1B[7mPortal User\x1B[27m"
read user

echo -e "\x1B[7mPortal Password\x1B[27m"
read -s password

cd docker

docker build \
--build-arg USER=$user \
--build-arg PASSWORD=$password \
--build-arg MACHINE_AGENT_VERSION=$machine_agent_version \
--build-arg JAVA_AGENT_VERSION=$java_agent_version \
-t $image:latest .

exit 0
