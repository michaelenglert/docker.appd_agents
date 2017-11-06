AppDynamics Agents Docker Image
======
![Build Status](https://jenkins.appd.duckdns.org/buildStatus/icon?job=DOCKER_appd_agents)
# Introduction
This Docker Image contains the AppDynamics Machine Agent and the Java Agent.
# Build
Use the [image.sh] Script to build the Docker Image. It will interactively ask for:
* ```Version``` -  AppDynamics Agent Version. Is also used as tag for the image
* ```Portal User``` - AppDynamics Portal User Name to download the agents.
* ```Portal Password``` - AppDynamics Portal Password to download the agents.
* ```Image Name``` - Image Name for the Docker Image

# Run
Sample ```docker run``` command:
```
docker run -d --name <container-name> \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /:/hostroot:ro \
    -v <host-folder>:/app-agent \
    -e APPDYNAMICS_CONTROLLER_HOST_NAME="<controller-host>" \
    -e APPDYNAMICS_CONTROLLER_PORT="<controller-port>" \
    -e APPDYNAMICS_AGENT_ACCOUNT_NAME="<account-name>" \
    -e APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="<account-access-key>" \
    -e APPDYNAMICS_SIM_ENABLED="true/false" \
    -e APPDYNAMICS_CONTROLLER_SSL_ENABLED="true/false" \
    -e APPDYNAMICS_DOCKER_ENABLED="true/false" \
    <image-name>
```
Notes:
* If you enable Docker Visibility it is required to mount the Docker Socket into the container
* Access to the hostroot is used for gathering Metrics from the underlying Host

[image.sh]: /image.sh
