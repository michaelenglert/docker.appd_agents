#!/bin/bash

sed -i -e "/<controller-port>/c\<controller-port>$APPDYNAMICS_CONTROLLER_PORT<\/controller-port>" /app-agent-temp/conf/controller-info.xml
sed -i -e "/<controller-ssl-enabled>/c\<controller-ssl-enabled>$APPDYNAMICS_CONTROLLER_SSL_ENABLED<\/controller-ssl-enabled>" /app-agent-temp/conf/controller-info.xml
sed -i -e "/<account-name>/c\<account-name>$APPDYNAMICS_AGENT_ACCOUNT_NAME<\/account-name>" /app-agent-temp/conf/controller-info.xml
sed -i -e "/<account-access-key>/c\<account-access-key>$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY<\/account-access-key>" /app-agent-temp/conf/controller-info.xml
sed -i -e "/<agent-runtime-dir>/c\<agent-runtime-dir>\/<\/agent-runtime-dir>" /app-agent-temp/conf/controller-info.xml
sed -i -e "/<\!-- property name=\"config-poll-interval\"/c\<property name=\"appdynamics.jvm.shutdown.mark.node.as.historical\" value=\"true\" \/>" /app-agent-temp/ver*/conf/app-agent-config.xml

cp /app-agent-temp/conf/controller-info.xml /app-agent-temp/ver*/conf/controller-info.xml
cp -r /app-agent-temp/* /app-agent/
rm -rf /app-agent-temp
