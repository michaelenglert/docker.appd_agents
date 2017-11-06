AppDynamics Agents Docker Image
======
![Build Status](https://jenkins.appd.duckdns.org/buildStatus/icon?job=DOCKER_appd_agents)
# Introduction
This Docker Image contains the AppDynamics Machine Agent and the Java Agent.
# Build
Use the [build.sh] Script to build the Docker Image. It will interactively ask for:
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
* Server Visibility and Docker Visibility require a *Server Visibility License*

# Sample Application
```
docker run -d --name <app-container-name> \
    -v <host-folder>:/app-agent \
    -e APPDYNAMICS_AGENT_APPLICATION_NAME="<application-name>" \
    -e APPDYNAMICS_AGENT_TIER_NAME="<tier-name>" \
    -e CATALINA_OPTS="-Dappdynamics.agent.reuse.nodeName.prefix=$APPDYNAMICS_AGENT_TIER -Dappdynamics.agent.reuse.nodeName=true \ -javaagent:/app-agent/javaagent.jar"
    snasello/liferay-6.2
```

[image.sh]: /image.sh
