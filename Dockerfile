FROM debian:jessie
MAINTAINER Michael Englert <michi.eng@gmail.com>

ARG USER
ARG PASSWORD
ARG BASEURL
ARG VERSION

ENV APPDYNAMICS_CONTROLLER_HOST_NAME="always.appd.duckdns.org" \
    APPDYNAMICS_CONTROLLER_PORT="443" \
    APPDYNAMICS_AGENT_ACCOUNT_NAME="customer1" \
    APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="H16h53cur3" \
    APPDYNAMICS_SIM_ENABLED="true" \
    APPDYNAMICS_CONTROLLER_SSL_ENABLED="true"

ENV APPDYNAMICS_AGENT_UNIQUE_HOST_ID \
    APPDYNAMICS_MACHINE_HIERARCHY_PATH \
    APPDYNAMICS_AGENT_APPLICATION_NAME \
    APPDYNAMICS_AGENT_TIER_NAME \
    APPDYNAMICS_AGENT_NODE_NAME

VOLUME /app-agent

ADD setup_agent.sh /

RUN apt-get update \
    && apt-get install -q -y --fix-missing unzip curl \
    && chmod +x /setup_agent.sh \
    && mkdir /machine-agent \
    && curl --referer http://www.appdynamics.com -c cookies.txt -d "username=$USER&password=$PASSWORD" https://login.appdynamics.com/sso/login/ \
    && curl -L -o /machine-agent.zip -b /cookies.txt $BASEURL/machine-bundle/$VERSION/machineagent-bundle-64bit-linux-$VERSION.zip \
    && curl -L -o /app-agent.zip -b /cookies.txt $BASEURL/sun-jvm/$VERSION/AppServerAgent-$VERSION.zip \
    && unzip /machine-agent.zip -d /machine-agent \
    && unzip /app-agent.zip -d /app-agent-temp/ \
    && sed -i -e "/<\/controller-info>/i <docker-enabled>true<\/docker-enabled>" /machine-agent/conf/controller-info.xml \
    && apt-get remove --purge -q -y curl unzip \
    && apt-get autoremove -q -y \
    && apt-get clean -q -y \
    && rm -rf /machine-agent.zip /app-agent.zip /cookies.txt /tmp/*

CMD /bin/bash -c "/setup_agent.sh" && /machine-agent/bin/machine-agent start
