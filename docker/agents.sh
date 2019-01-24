#!/bin/bash

APPD_APP_AGENT_TMP="$APPD_HOME/appagenttemp/"
APPD_MACHINE="$APPD_HOME/machineagent"
APPD_ANALYTICS="$APPD_MACHINE/monitors/analytics-agent"
APPD_MEMORY="256m"

# Configure App Agent
if [ -d "$APPD_APP_AGENT_TMP" ]; then
    find $APPD_APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/-host>/c\<controller-host>$APPDYNAMICS_CONTROLLER_HOST_NAME<\/controller-host>\" {}" \;
    find $APPD_APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/-port>/c\<controller-port>$APPDYNAMICS_CONTROLLER_PORT<\/controller-port>\" {}" \;
    find $APPD_APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/-ssl-enabled>/c\<controller-ssl-enabled>$APPDYNAMICS_CONTROLLER_SSL_ENABLED<\/controller-ssl-enabled>\" {}" \;
    find $APPD_APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/<account-name>/c\<account-name>$APPDYNAMICS_AGENT_ACCOUNT_NAME<\/account-name>\" {}" \;
    find $APPD_APP_AGENT_TMP \
        -iname controller-info.xml \
        -exec /bin/sh -c "sed -i -e \"/-key>/c\<account-access-key>$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY<\/account-access-key>\" {}" \;
    cp -r $APPD_APP_AGENT_TMP/* $APPD_HOME/appagent
    rm -rf $APPD_APP_AGENT_TMP
    echo "$(date -u +%d\ %b\ %Y\ %H:%M:%S) INFO [appd.sh] \
        App Agent controller-info.xml configured."
else
    echo "$(date -u +%d\ %b\ %Y\ %H:%M:%S) INFO [appd.sh] \
        APPD_APP_AGENT_TMP directory ($APPD_APP_AGENT_TMP) does not exist --> App Agent controller-info.xml is already configured."
fi

# Configure Docker Visibility
find $APPD_MACHINE \
    -iname DockerMonitoring.yml \
    -exec /bin/sh -c "sed -i -e \"s/\.\*\[ \]-Dappdynamics//\" {}" \;
echo "$(date -u +%d\ %b\ %Y\ %H:%M:%S) INFO [appd.sh] \
    Docker Visibility Process Selector generified."

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
    echo "$(date -u +%d\ %b\ %Y\ %H:%M:%S) INFO [appd.sh] \
        APPDYNAMICS_CONTROLLER_SSL_ENABLED not set. It will default to false."
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
    APPD_CONTROLLER_URL="$APPDYNAMICS_CONTROLLER_PROTOCOL:\/\/$APPDYNAMICS_CONTROLLER_HOST_NAME:$APPDYNAMICS_CONTROLLER_PORT"
    sed -i -e "s/false/true/" \
        $APPD_ANALYTICS/monitor.xml
    sed -i -e "/controller.url/c\ad\.controller\.url=$APPD_CONTROLLER_URL" \
        $APPD_ANALYTICS/conf/analytics-agent.properties
    sed -i -e "/http.event.name/c\http.event.name=$APPDYNAMICS_AGENT_ACCOUNT_NAME" \
        $APPD_ANALYTICS/conf/analytics-agent.properties
    sed -i -e "/http.event.accountName/c\http.event.accountName=$APPDYNAMICS_AGENT_GLOBAL_ACCOUNT_NAME" \
        $APPD_ANALYTICS/conf/analytics-agent.properties
    sed -i -e "/http.event.accessKey/c\http.event.accessKey=$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY" \
        $APPD_ANALYTICS/conf/analytics-agent.properties
    sed -i -e "/http.event.endpoint/c\http.event.endpoint=$APPDYNAMICS_ANALYTICS_EVENT_ENDPOINT" \
        $APPD_ANALYTICS/conf/analytics-agent.properties
    echo "$(date -u +%d\ %b\ %Y\ %H:%M:%S) INFO [appd.sh] \
        Analytics enabled."
else
    echo "$(date -u +%d\ %b\ %Y\ %H:%M:%S) INFO [appd.sh] \
        Analytics not enabled cause either APPDYNAMICS_AGENT_GLOBAL_ACCOUNT_NAME or APPDYNAMICS_ANALYTICS_EVENT_ENDPOINT is missing."
fi

APPD_APP_AGENT_VERSIONS="$(find $APPD_HOME/appagent/ -name ver4*)"

if [ "$APPDYNAMICS_STDOUT_LOGGING" = "true" ]
then
    if [ ! -e $APPD_MACHINE/conf/logging/log4j.xml.backup ]
    then
        cp  $APPD_MACHINE/conf/logging/log4j.xml \
            $APPD_MACHINE/conf/logging/log4j.xml.backup
    fi
    sed -i -e 's/ref="\w*"/ref="ConsoleAppender"/g' \
        $APPD_MACHINE/conf/logging/log4j.xml
    sed -i -e 's/ABSOLUTE/DATE/' \
        $APPD_MACHINE/conf/logging/log4j.xml
    
    while read -r APPD_APP_AGENT_VERSION; do
        if [ -e $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml ]
        then
            if [ ! -e $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml.backup ]
            then
                cp  $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml \
                    $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml.backup
            fi
            sed -i -e 's/ref="\w*"/ref="ConsoleAppender"/g' \
                $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml
            sed -i -e 's/ABSOLUTE/DATE/' \
                $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml
        elif [ -e $APPD_APP_AGENT_VERSION/conf/logging/log4j2.xml ]
        then
            if [ ! -e $APPD_APP_AGENT_VERSION/conf/logging/log4j2.xml.backup ]
            then
                cp  $APPD_APP_AGENT_VERSION/conf/logging/log4j2.xml \
                    $APPD_APP_AGENT_VERSION/conf/logging/log4j2.xml.backup
            fi
            sed -i -e 's/ref="\w*"/ref="ConsoleAppender"/g' \
                $APPD_APP_AGENT_VERSION/conf/logging/log4j2.xml
            sed -i -e 's/ABSOLUTE/DATE/' \
                $APPD_APP_AGENT_VERSION/conf/logging/log4j2.xml
        fi
    done <<< "$APPD_APP_AGENT_VERSIONS"
    echo "$(date -u +%d\ %b\ %Y\ %H:%M:%S) INFO [appd.sh] Logging set to Standard Out."
elif [ "$APPDYNAMICS_STDOUT_LOGGING" = "false" ]
then
    if [ -e $APPD_MACHINE/conf/logging/log4j.xml.backup ]
    then
        cp  $APPD_MACHINE/conf/logging/log4j.xml.backup \
            $APPD_MACHINE/conf/logging/log4j.xml
    fi
    while read -r APPD_APP_AGENT_VERSION; do
        if [ -e $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml.backup ]
        then
            cp  $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml.backup \
                $APPD_APP_AGENT_VERSION/conf/logging/log4j.xml
        fi
    done <<< "$APPD_APP_AGENT_VERSIONS"
    echo "$(date -u +%d\ %b\ %Y\ %H:%M:%S) INFO [appd.sh] Logging set to File."
fi

# Cleanup old .id files
find $APPD_HOME -iname *.id -exec /bin/sh -c "rm -rf {}" \;

if [ -n "${APPDYNAMICS_MEMORY:+1}" ]
then
    APPD_MEMORY=${APPDYNAMICS_MEMORY}
fi

$APPD_MACHINE/bin/machine-agent -Xmx$APPD_MEMORY -Xms$APPD_MEMORY start

exit 0