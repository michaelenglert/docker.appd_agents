FROM debian:jessie
LABEL maintainer="Michael Englert <michi.eng@gmail.com>"

ARG BASEURL
ARG MACHINE_AGENT_VERSION
ARG APP_AGENT_VERSION
ARG USER
ARG PASSWORD

ENV APPDYNAMICS_CONTROLLER_HOST_NAME="" \
    APPDYNAMICS_CONTROLLER_PORT="8090" \
    APPDYNAMICS_AGENT_ACCOUNT_NAME="customer1" \
    APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="" \
    APPDYNAMICS_SIM_ENABLED="false" \
    APPDYNAMICS_DOCKER_ENABLED="false" \
    APPDYNAMICS_CONTROLLER_SSL_ENABLED="false"

VOLUME /opt/appdynamics/appagent

ADD appd.sh /opt/appdynamics/

RUN apt-get update \
    && apt-get install -q -y --fix-missing unzip curl \
    && chmod +x /opt/appdynamics/appd.sh \
    && mkdir -p /opt/appdynamics/machineagent \
    && mkdir -p /opt/appdynamics/appagent \
    && curl --referer http://www.appdynamics.com -c /tmp/cookies.txt -d "username=$USER&password=$PASSWORD" https://login.appdynamics.com/sso/login/ \
    && curl -L -b /tmp/cookies.txt -o /tmp/machineagent.zip $BASEURL/machine-bundle/$MACHINE_AGENT_VERSION/machineagent-bundle-64bit-linux-$MACHINE_AGENT_VERSION.zip \
    && curl -L -b /tmp/cookies.txt -o /tmp/appagent.zip $BASEURL/sun-jvm/$APP_AGENT_VERSION/AppServerAgent-$APP_AGENT_VERSION.zip \
    && unzip /tmp/machineagent.zip -d /opt/appdynamics/machineagent \
    && unzip /tmp/appagent.zip -d /opt/appdynamics/appagenttemp \
    && apt-get remove --purge -q -y curl unzip \
    && apt-get autoremove -q -y \
    && apt-get clean -q -y \
    && rm -rf /tmp/*

CMD /bin/bash -c "/opt/appdynamics/appd.sh" && /opt/appdynamics/machineagent/bin/machine-agent start
