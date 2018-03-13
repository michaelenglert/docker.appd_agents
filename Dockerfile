FROM debian:jessie
MAINTAINER Michael Englert <michi.eng@gmail.com>

ARG BASEURL
ARG MACHINE_AGENT_VERSION
ARG APP_AGENT_VERSION

ENV APPDYNAMICS_CONTROLLER_HOST_NAME="" \
    APPDYNAMICS_CONTROLLER_PORT="" \
    APPDYNAMICS_AGENT_ACCOUNT_NAME="" \
    APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="" \
    APPDYNAMICS_SIM_ENABLED="" \
    APPDYNAMICS_DOCKER_ENABLED="" \
    APPDYNAMICS_CONTROLLER_SSL_ENABLED=""

VOLUME /app-agent

ADD setup_agent.sh /

RUN apt-get update \
    && apt-get install -q -y --fix-missing unzip curl \
    && chmod +x /setup_agent.sh \
    && mkdir /machine-agent \
    && curl -L -o /machine-agent.zip -b /cookies.txt $BASEURL/machine/$MACHINE_AGENT_VERSION/machineagent-bundle-64bit-linux-$MACHINE_AGENT_VERSION.zip \
    && curl -L -o /app-agent.zip -b /cookies.txt $BASEURL/java/$APP_AGENT_VERSION/AppServerAgent-$APP_AGENT_VERSION.zip \
    && unzip /machine-agent.zip -d /machine-agent \
    && unzip /app-agent.zip -d /app-agent-temp/ \
    && apt-get remove --purge -q -y curl unzip \
    && apt-get autoremove -q -y \
    && apt-get clean -q -y \
    && rm -rf /machine-agent.zip /app-agent.zip /cookies.txt /tmp/*

CMD /bin/bash -c "/setup_agent.sh" && /machine-agent/bin/machine-agent start
