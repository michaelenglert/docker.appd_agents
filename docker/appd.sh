#!/bin/sh

# Configure App Agent
if [ -d "$APP_AGENT_TMP" ]; then
    find $APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/<controller-host>/c\<controller-host>$APPDYNAMICS_CONTROLLER_HOST_NAME<\/controller-host>\" {}" \;
    find $APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/<controller-port>/c\<controller-port>$APPDYNAMICS_CONTROLLER_PORT<\/controller-port>\" {}" \;
    find $APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/<controller-ssl-enabled>/c\<controller-ssl-enabled>$APPDYNAMICS_CONTROLLER_SSL_ENABLED<\/controller-ssl-enabled>\" {}" \;
    find $APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/<account-name>/c\<account-name>$APPDYNAMICS_AGENT_ACCOUNT_NAME<\/account-name>\" {}" \;
    find $APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/<account-access-key>/c\<account-access-key>$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY<\/account-access-key>\" {}" \;
    cp -r $APP_AGENT_TMP/* /opt/appdynamics/appagent
    rm -rf $APP_AGENT_TMP
    echo "App Agent controller-info.xml configured."
else
    echo "APP_AGENT_TMP directory ($APP_AGENT_TMP) does not exist --> App Agent controller-info.xml is already configured."
fi 

# Configure Docker Visibility
find /opt/appdynamics/machineagent/ \
    -iname DockerMonitoring.yml \
    -exec /bin/sh -c "sed -i -e \"s/\.\*\[ \]-Dappdynamics//\" {}" \;
echo "Docker Visibility Process Selector generified."

# If the corresponding Environment Variables are set the Analytics Plugin will be enabled by default
if [ -n "${APPDYNAMICS_CONTROLLER_SSL_ENABLED:+1}" ]
then
    if [ "$APPDYNAMICS_CONTROLLER_SSL_ENABLED" = "false" ]
    then
        APPDYNAMICS_CONTROLLER_PROTOCOL="http"
    elif [ "$APPDYNAMICS_CONTROLLER_SSL_ENABLED" = "true" ]
    then
        APPDYNAMICS_CONTROLLER_PROTOCOL="https"
    fi
else
    echo "APPDYNAMICS_CONTROLLER_SSL_ENABLED not set. It will default to false."
    APPDYNAMICS_CONTROLLER_PROTOCOL="http"
fi
if [ -n "${APPDYNAMICS_AGENT_GLOBAL_ACCOUNT_NAME:+1}" ] && [ -n "${APPDYNAMICS_ANALYTICS_EVENT_ENDPOINT:+1}" ]
then
    ANALYTICS_AGENT="/opt/appdynamics/machineagent/monitors/analytics-agent"
    if [ -e $ANALYTICS_AGENT/conf/analytics-agent.properties.backup ]
    then
        cp $ANALYTICS_AGENT/conf/analytics-agent.properties.backup $ANALYTICS_AGENT/conf/analytics-agent.properties
    else
        cp $ANALYTICS_AGENT/conf/analytics-agent.properties $ANALYTICS_AGENT/cong/analytics-agent.properties.backup
    fi
    sed -i "s@false@true@" $ANALYTICS_AGENT/monitor.xml
    sed -i "s@http:\/\/localhost:8090@$APPDYNAMICS_CONTROLLER_PROTOCOL:\/\/$APPDYNAMICS_CONTROLLER_HOST_NAME:$APPDYNAMICS_CONTROLLER_PORT@" $ANALYTICS_AGENT/conf/analytics-agent.properties
    sed -i "s@=customer1@=$APPDYNAMICS_AGENT_ACCOUNT_NAME@" $ANALYTICS_AGENT/conf/analytics-agent.properties
    sed -i "s@analytics-customer1@$APPDYNAMICS_AGENT_GLOBAL_ACCOUNT_NAME@" $ANALYTICS_AGENT/conf/analytics-agent.properties
    sed -i "s@your-account-access-key@$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY@" $ANALYTICS_AGENT/conf/analytics-agent.properties
    sed -i "s@http:\/\/localhost:9080@$APPDYNAMICS_ANALYTICS_EVENT_ENDPOINT@" $ANALYTICS_AGENT/conf/analytics-agent.properties
    echo "Analytics enabled."
else
    echo "Analytics not enabled cause either APPDYNAMICS_AGENT_GLOBAL_ACCOUNT_NAME or APPDYNAMICS_ANALYTICS_EVENT_ENDPOINT is missing."
fi

find /opt/appdynamics/ -iname *.id -exec /bin/sh -c "rm -rf {}" \;

exit 0
