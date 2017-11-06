docker run -d --name appd-agents \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /:/hostroot:ro \
    -v /tmp/app-agent:/app-agent \
    -e APPDYNAMICS_CONTROLLER_HOST_NAME="" \
    -e APPDYNAMICS_CONTROLLER_PORT="" \
    -e APPDYNAMICS_AGENT_ACCOUNT_NAME="customer1" \
    -e APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="" \
    -e APPDYNAMICS_SIM_ENABLED="true" \
    -e APPDYNAMICS_CONTROLLER_SSL_ENABLED="false" \
    -e APPDYNAMICS_DOCKER_ENABLED="true" \
    michi/appd-agents:4.3.7.3
