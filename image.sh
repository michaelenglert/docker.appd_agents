#!/bin/bash

echo -e "\x1B[7mVersion\x1B[27m"
read version

echo -e "\x1B[7mPortal User\x1B[27m"
read user

echo -e "\x1B[7mPortal Password\x1B[27m"
read -s password

echo -e "\x1B[7mImage Name\x1B[27m"
read image

docker build \
--build-arg USER=$user \
--build-arg PASSWORD=$password \
--build-arg BASEURL=https://aperture.appdynamics.com/download/prox/download-file \
--build-arg VERSION=$version \
-t $image:$version .
