FROM maven:3.5-jdk-8-alpine

WORKDIR /build
ADD Handler /build/Handler
RUN cd Handler && \
    mvn clean compile test assembly:single

FROM openjdk:jre-alpine

WORKDIR /app
COPY --from=0 /build/Handler/target/*.jar /app/Handler.jar

ADD https://github.com/openfaas/faas/releases/download/0.6.5/fwatchdog /usr/bin
RUN chmod +x /usr/bin/fwatchdog

ENV fprocess="java -jar Handler.jar"

HEALTHCHECK --interval=1s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
