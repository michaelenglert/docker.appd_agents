docker run -d --name <app-container-name> \
    -v <host-folder>:/app-agent \
    -e APPDYNAMICS_AGENT_APPLICATION_NAME="<application-name>" \
    -e APPDYNAMICS_AGENT_TIER_NAME="<tier-name>" \
    -e APPDYNAMICS_JAVA_AGENT_REUSE_NODE_NAME="true" \
    -e APPDYNAMICS_JAVA_AGENT_REUSE_NODE_NAME_PREFIX="<tier-name>" \
    -e CATALINA_OPTS="-javaagent:/java-agent/javaagent.jar" \
    snasello/liferay-6.2
