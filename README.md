AppDynamics Agents Docker Image
======
# Introduction
This Docker Image contains the AppDynamics Machine Agent and the Java Agent.
# Build
Use the [build.sh] Script to build the Docker Image. It will interactively ask for:
* ```MACHINE_AGENT_VERSION``` -  AppDynamics Machine Agent Version.
* ```JAVA_AGENT_VERSION``` -  AppDynamics Java Agent Version.
* ```Image Name``` - Image Name for the Docker Image.
* ```USER``` -  AppDynamics Portal User.
* ```PASSWORD``` - AppDynamics Portal Password.

# Build - Offline
If you can't dowload the Agent Bits from the machine the Docker Image will be built on you can also build it offline:
* Clone/Download the Repository
* Go into the offline folder ```cd docker-offline```
* Download the latest ```Machine Agent (zip)``` and ```Java Agent - Sun and JRockit JVM (zip)``` from the [AppDynamics Download Server]
* Copy ```Machine Agent (zip)``` as ```machine-agent.zip``` into the ```docker-offline``` folder
* Copy ```Java Agent - Sun and JRockit JVM (zip)``` as ```java-agent.zip``` into the ```docker-offline``` folder
* Build the Docker Image ```docker build -t <image-name> .```


# Run
Sample ```docker run``` command:
```
docker run -d --name <container-name> \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /:/hostroot:ro \
    -v <host-folder>:/opt/appdynamics/java-agent \
    -e APPDYNAMICS_CONTROLLER_HOST_NAME="<controller-host>" \
    -e APPDYNAMICS_CONTROLLER_PORT="<controller-port>" \
    -e APPDYNAMICS_AGENT_ACCOUNT_NAME="<account-name>" \
    -e APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="<account-access-key>" \
    -e APPDYNAMICS_SIM_ENABLED="true/false" \
    -e APPDYNAMICS_CONTROLLER_SSL_ENABLED="true/false" \
    -e APPDYNAMICS_DOCKER_ENABLED="true/false" \
    -e APPDYNAMICS_STDOUT_LOGGING="true/false" \
    -e APPDYNAMICS_AGENT_GLOBAL_ACCOUNT_NAME="<global-account-name>" \
    -e APPDYNAMICS_ANALYTICS_EVENT_ENDPOINT="<events-service-url>" \
    <image-name>
```
Notes:
* If you enable Docker Visibility it is required to mount the Docker Socket into the container
* Access to the hostroot is used for gathering Metrics from the underlying Host
* Server Visibility and Docker Visibility require a *Server Visibility License*

# Sample Application
```
docker run -d --name <app-container-name> \
    -v <host-folder>:/java-agent \
    -e APPDYNAMICS_AGENT_APPLICATION_NAME="<application-name>" \
    -e APPDYNAMICS_AGENT_TIER_NAME="<tier-name>" \
    -e APPDYNAMICS_JAVA_AGENT_REUSE_NODE_NAME="true" \
    -e APPDYNAMICS_JAVA_AGENT_REUSE_NODE_NAME_PREFIX="<tier-name>" \
    -e CATALINA_OPTS="-javaagent:/java-agent/javaagent.jar" \
    snasello/liferay-6.2
```

[build.sh]: /build.sh
[AppDynamics Download Server]: https://download.appdynamics.com