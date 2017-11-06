docker run -d --name <app-container-name> \
    -v <host-folder>:/app-agent \
    -e APPDYNAMICS_AGENT_APPLICATION_NAME="<application-name>" \
    -e APPDYNAMICS_AGENT_TIER_NAME="<tier-name>" \
    -e CATALINA_OPTS="-Dappdynamics.agent.reuse.nodeName.prefix=$APPDYNAMICS_AGENT_TIER -Dappdynamics.agent.reuse.nodeName=true -javaagent:/app-agent/javaagent.jar" \
    snasello/liferay-6.2
