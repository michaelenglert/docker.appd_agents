#!/bin/sh

APPD_ROOT="/opt/appdynamics"
APPD_APP_AGENT_TMP="$APPD_ROOT/appagenttemp/"
APPD_MACHINE="$APPD_ROOT/machineagent"
APPD_ANALYTICS="$APPD_MACHINE/monitors/analytics-agent"


# Configure App Agent
if [ -d "$APPD_APP_AGENT_TMP" ]; then
    find $APPD_APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/<controller-host>/c\<controller-host>$APPDYNAMICS_CONTROLLER_HOST_NAME<\/controller-host>\" {}" \;
    find $APPD_APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/<controller-port>/c\<controller-port>$APPDYNAMICS_CONTROLLER_PORT<\/controller-port>\" {}" \;
    find $APPD_APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/<controller-ssl-enabled>/c\<controller-ssl-enabled>$APPDYNAMICS_CONTROLLER_SSL_ENABLED<\/controller-ssl-enabled>\" {}" \;
    find $APPD_APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/<account-name>/c\<account-name>$APPDYNAMICS_AGENT_ACCOUNT_NAME<\/account-name>\" {}" \;
    find $APPD_APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/<account-access-key>/c\<account-access-key>$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY<\/account-access-key>\" {}" \;
    cp -r $APPD_APP_AGENT_TMP/* /opt/appdynamics/appagent
    rm -rf $APPD_APP_AGENT_TMP
    echo "App Agent controller-info.xml configured."
else
    echo "APPD_APP_AGENT_TMP directory ($APPD_APP_AGENT_TMP) does not exist --> App Agent controller-info.xml is already configured."
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
    if [ -e $APPD_ANALYTICS/conf/analytics-agent.properties.backup ]
    then
        cp $APPD_ANALYTICS/conf/analytics-agent.properties.backup $APPD_ANALYTICS/conf/analytics-agent.properties
    else
        cp $APPD_ANALYTICS/conf/analytics-agent.properties $APPD_ANALYTICS/conf/analytics-agent.properties.backup
    fi
    sed -i "s@false@true@" $APPD_ANALYTICS/monitor.xml
    sed -i "s@http:\/\/localhost:8090@$APPDYNAMICS_CONTROLLER_PROTOCOL:\/\/$APPDYNAMICS_CONTROLLER_HOST_NAME:$APPDYNAMICS_CONTROLLER_PORT@" $APPD_ANALYTICS/conf/analytics-agent.properties
    sed -i "s@=customer1@=$APPDYNAMICS_AGENT_ACCOUNT_NAME@" $APPD_ANALYTICS/conf/analytics-agent.properties
    sed -i "s@analytics-customer1@$APPDYNAMICS_AGENT_GLOBAL_ACCOUNT_NAME@" $APPD_ANALYTICS/conf/analytics-agent.properties
    sed -i "s@your-account-access-key@$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY@" $APPD_ANALYTICS/conf/analytics-agent.properties
    sed -i "s@http:\/\/localhost:9080@$APPDYNAMICS_ANALYTICS_EVENT_ENDPOINT@" $APPD_ANALYTICS/conf/analytics-agent.properties
    echo "Analytics enabled."
else
    echo "Analytics not enabled cause either APPDYNAMICS_AGENT_GLOBAL_ACCOUNT_NAME or APPDYNAMICS_ANALYTICS_EVENT_ENDPOINT is missing."
fi

APPD_APP_AGENT_VERSION="$(find /opt/appdynamics/appagent/ -name ver4*)"

if [ "$APPDYNAMICS_STDOUT_LOGGING" = "true" ]
then
    if [ ! -e $APPD_MACHINE/conf/logging/log4j.xml.backup ]
    then
        cp  $APPD_MACHINE/conf/logging/log4j.xml \
            $APPD_MACHINE/conf/logging/log4j.xml.backup
    fi
    if [ ! -e $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml.backup ]
    then
        cp  $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml \
            $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml.backup
    fi
    sed -i -e 's/ref="\w*"/ref="ConsoleAppender"/g' \
        $APPD_MACHINE/conf/logging/log4j.xml
    sed -i -e 's/ref="\w*"/ref="ConsoleAppender"/g' \
        $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml
    echo "Logging set to Standard Out."
elif [ "$APPDYNAMICS_STDOUT_LOGGING" = "false" ]
then
    if [ -e $APPD_MACHINE/conf/logging/log4j.xml.backup ]
    then
        cp  $APPD_MACHINE/conf/logging/log4j.xml.backup \
            $APPD_MACHINE/conf/logging/log4j.xml
    fi
    if [ -e $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml.backup ]
    then
        cp  $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml.backup \
            $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml
    fi
    echo "Logging set to File."
fi

# Cleanup old .id files
find /opt/appdynamics/ -iname *.id -exec /bin/sh -c "rm -rf {}" \;

exit 0