#!/bin/bash

# Configure App Agent
find /opt/appdynamics/appagenttemp/ -iname controller-info.xml -exec /bin/bash -c "sed -i -e \"/<controller-host>/c\<controller-host>$APPDYNAMICS_CONTROLLER_HOST_NAME<\/controller-host>\" {}" \;
find /opt/appdynamics/appagenttemp/ -iname controller-info.xml -exec /bin/bash -c "sed -i -e \"/<controller-port>/c\<controller-port>$APPDYNAMICS_CONTROLLER_PORT<\/controller-host>\" {}" \;
find /opt/appdynamics/appagenttemp/ -iname controller-info.xml -exec /bin/bash -c "sed -i -e \"/<controller-ssl-enabled>/c\<controller-ssl-enabled>$APPDYNAMICS_CONTROLLER_SSL_ENABLED<\/controller-host>\" {}" \;
find /opt/appdynamics/appagenttemp/ -iname controller-info.xml -exec /bin/bash -c "sed -i -e \"/<account-name>/c\<account-name>$APPDYNAMICS_AGENT_ACCOUNT_NAME<\/account-name>\" {}" \;
find /opt/appdynamics/appagenttemp/ -iname controller-info.xml -exec /bin/bash -c "sed -i -e \"/<account-access-key>/c\<account-access-key>$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY<\/account-access-key>\" {}" \;
find /opt/appdynamics/appagenttemp/ -iname controller-info.xml -exec /bin/bash -c "sed -i -e \"/<agent-runtime-dir>/c\<agent-runtime-dir>\/<\/agent-runtime-dir>\" {}" \;

cp -r /opt/appdynamics/appagenttemp/* /opt/appdynamics/appagent
rm -rf /opt/appdynamics/appagenttemp/


# Configure Docker Visibility
find /opt/appdynamics/machineagent/ -iname DockerMonitoring.yml -exec /bin/bash -c "sed -i -e \"s/\.\*\[ \]-Dappdynamics//\" {}" \;

exit 0
