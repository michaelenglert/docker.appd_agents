FROM alpine AS builder
LABEL maintainer="Michael Englert <michi.eng@gmail.com>"

ARG BASEURL="https://download.appdynamics.com/download/prox/download-file"
ARG MACHINE_AGENT_VERSION
ARG JAVA_AGENT_VERSION
ARG USER
ARG PASSWORD

ENV APPD_HOME="/opt/appdynamics"

ADD agents.sh ${APPD_HOME}/

RUN apk update  
RUN apk upgrade
RUN apk add unzip curl
RUN chmod +x ${APPD_HOME}/agents.sh
RUN mkdir -p ${APPD_HOME}/machineagent
RUN mkdir -p ${APPD_HOME}/java-agent
RUN mkdir -p ${APPD_HOME}/java-agenttemp
RUN curl --referer http://www.appdynamics.com -c /tmp/cookies.txt -d "username=${USER}&password=${PASSWORD}" https://login.appdynamics.com/sso/login/
RUN curl -L -b /tmp/cookies.txt -o /tmp/machineagent.zip ${BASEURL}/machine/${MACHINE_AGENT_VERSION}/MachineAgent-${MACHINE_AGENT_VERSION}.zip
RUN curl -L -b /tmp/cookies.txt -o /tmp/java-agent.zip ${BASEURL}/sun-jvm/${JAVA_AGENT_VERSION}/AppServerAgent-${JAVA_AGENT_VERSION}.zip
RUN unzip /tmp/machineagent.zip -d ${APPD_HOME}/machineagent
RUN unzip /tmp/java-agent.zip -d ${APPD_HOME}/java-agenttemp


FROM openjdk:8-jre-slim
LABEL maintainer="Michael Englert <michi.eng@gmail.com>"

ENV APPD_HOME="/opt/appdynamics" \
    APPDYNAMICS_CONTROLLER_HOST_NAME="" \
    APPDYNAMICS_CONTROLLER_PORT="8090" \
    APPDYNAMICS_AGENT_ACCOUNT_NAME="customer1" \
    APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="" \
    APPDYNAMICS_SIM_ENABLED="false" \
    APPDYNAMICS_DOCKER_ENABLED="false" \
    APPDYNAMICS_CONTROLLER_SSL_ENABLED="false" \
    APPDYNAMICS_STDOUT_LOGGING="true"

VOLUME ${APPD_HOME}/java-agent

COPY --from=builder ${APPD_HOME} ${APPD_HOME}

RUN apt-get update \
    && apt-get install --fix-missing -q -y procps

CMD [ "/bin/bash", "-c", "${APPD_HOME}/agents.sh" ]