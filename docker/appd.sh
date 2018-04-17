#!/bin/bash

# Configure App Agent
find /opt/appdynamics/appagenttemp/ -iname controller-info.xml -exec /bin/bash -c "sed -i -e \"/<controller-host>/c\<controller-host>$APPDYNAMICS_CONTROLLER_HOST_NAME<\/controller-host>\" {}" \;
find /opt/appdynamics/appagenttemp/ -iname controller-info.xml -exec /bin/bash -c "sed -i -e \"/<controller-port>/c\<controller-port>$APPDYNAMICS_CONTROLLER_PORT<\/controller-port>\" {}" \;
find /opt/appdynamics/appagenttemp/ -iname controller-info.xml -exec /bin/bash -c "sed -i -e \"/<controller-ssl-enabled>/c\<controller-ssl-enabled>$APPDYNAMICS_CONTROLLER_SSL_ENABLED<\/controller-ssl-enabled>\" {}" \;
find /opt/appdynamics/appagenttemp/ -iname controller-info.xml -exec /bin/bash -c "sed -i -e \"/<account-name>/c\<account-name>$APPDYNAMICS_AGENT_ACCOUNT_NAME<\/account-name>\" {}" \;
find /opt/appdynamics/appagenttemp/ -iname controller-info.xml -exec /bin/bash -c "sed -i -e \"/<account-access-key>/c\<account-access-key>$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY<\/account-access-key>\" {}" \;
find /opt/appdynamics/appagenttemp/ -iname controller-info.xml -exec /bin/bash -c "sed -i -e \"/<agent-runtime-dir>/c\<agent-runtime-dir>\/<\/agent-runtime-dir>\" {}" \;

cp -r /opt/appdynamics/appagenttemp/* /opt/appdynamics/appagent
rm -rf /opt/appdynamics/appagenttemp/


# Configure Docker Visibility
find /opt/appdynamics/machineagent/ -iname DockerMonitoring.yml -exec /bin/bash -c "sed -i -e \"s/\.\*\[ \]-Dappdynamics//\" {}" \;

# If the corresponding Environment Variables are set the Analytics Plugin will be enabled by default
if [ -n "${APPDYNAMICS_CONTROLLER_SSL_ENABLED:+1}" ]
then
    if [ "$APPDYNAMICS_CONTROLLER_SSL_ENABLED" == "false" ]
    then
        APPDYNAMICS_CONTROLLER_PROTOCOL="http"
    elif [ "$APPDYNAMICS_CONTROLLER_SSL_ENABLED" == "true" ]
    then
        APPDYNAMICS_CONTROLLER_PROTOCOL="https"
    fi
else
    echo "APPDYNAMICS_CONTROLLER_SSL_ENABLED not set. It will default to false."
    APPDYNAMICS_CONTROLLER_PROTOCOL="http"
fi
if [ -n "${APPDYNAMICS_AGENT_GLOBAL_ACCOUNT_NAME:+1}" ] && [ -n "${APPDYNAMICS_ANALYTICS_EVENT_ENDPOINT:+1}" ]
then
    sed -i "s@false@true@" /opt/appdynamics/machineagent/monitors/analytics-agent/monitor.xml
    sed -i "s@http:\/\/localhost:8090@$APPDYNAMICS_CONTROLLER_PROTOCOL:\/\/$APPDYNAMICS_CONTROLLER_HOST_NAME:$APPDYNAMICS_CONTROLLER_PORT@" /opt/appdynamics/machineagent/monitors/analytics-agent/conf/analytics-agent.properties
    sed -i "s@=customer1@=$APPDYNAMICS_AGENT_ACCOUNT_NAME@" /opt/appdynamics/machineagent/monitors/analytics-agent/conf/analytics-agent.properties
    sed -i "s@analytics-customer1@$APPDYNAMICS_AGENT_GLOBAL_ACCOUNT_NAME@" /opt/appdynamics/machineagent/monitors/analytics-agent/conf/analytics-agent.properties
    sed -i "s@your-account-access-key@$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY@" /opt/appdynamics/machineagent/monitors/analytics-agent/conf/analytics-agent.properties
    sed -i "s@http:\/\/localhost:9080@$APPDYNAMICS_ANALYTICS_EVENT_ENDPOINT@" /opt/appdynamics/machineagent/monitors/analytics-agent/conf/analytics-agent.properties
else
    echo "AppDynamics Analytics not enabled cause either APPDYNAMICS_AGENT_GLOBAL_ACCOUNT_NAME or APPDYNAMICS_ANALYTICS_EVENT_ENDPOINT is missing."
fi

find /opt/appdynamics/ -iname *.id -exec /bin/bash -c "rm -rf {}" \;

exit 0
