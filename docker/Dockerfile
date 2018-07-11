FROM alpine AS builder
LABEL maintainer="Michael Englert <michi.eng@gmail.com>"

ARG BASEURL
ARG MACHINE_AGENT_VERSION
ARG APP_AGENT_VERSION
ARG USER
ARG PASSWORD

ADD appd.sh /opt/appdynamics/

RUN apk update  
RUN apk upgrade
RUN apk add unzip curl
RUN chmod +x /opt/appdynamics/appd.sh
RUN mkdir -p /opt/appdynamics/machineagent
RUN mkdir -p /opt/appdynamics/appagent
RUN mkdir -p /opt/appdynamics/appagenttemp
RUN curl --referer http://www.appdynamics.com -c /tmp/cookies.txt -d "username=$USER&password=$PASSWORD" https://login.appdynamics.com/sso/login/
RUN curl -L -b /tmp/cookies.txt -o /tmp/machineagent.zip $BASEURL/machine/$MACHINE_AGENT_VERSION/MachineAgent-$MACHINE_AGENT_VERSION.zip
RUN curl -L -b /tmp/cookies.txt -o /tmp/appagent.zip $BASEURL/sun-jvm/$APP_AGENT_VERSION/AppServerAgent-$APP_AGENT_VERSION.zip
RUN unzip /tmp/machineagent.zip -d /opt/appdynamics/machineagent
RUN unzip /tmp/appagent.zip -d /opt/appdynamics/appagenttemp


FROM openjdk:8-jre-slim
LABEL maintainer="Michael Englert <michi.eng@gmail.com>"

ENV APPDYNAMICS_CONTROLLER_HOST_NAME="" \
    APPDYNAMICS_CONTROLLER_PORT="8090" \
    APPDYNAMICS_AGENT_ACCOUNT_NAME="customer1" \
    APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="" \
    APPDYNAMICS_SIM_ENABLED="false" \
    APPDYNAMICS_DOCKER_ENABLED="false" \
    APPDYNAMICS_CONTROLLER_SSL_ENABLED="false" \
    APPDYNAMICS_STDOUT_LOGGING="true"

VOLUME /opt/appdynamics/appagent

COPY --from=builder /opt/appdynamics /opt/appdynamics

CMD [ "/bin/sh", "-c", "/opt/appdynamics/appd.sh" ]