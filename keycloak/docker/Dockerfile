FROM quay.io/keycloak/keycloak:latest

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ADD --chown=keycloak:keycloak aws-java-sdk-core-1.12.410.jar /opt/keycloak/providers/aws-java-sdk-core-1.12.410.jar
ADD --chown=keycloak:keycloak aws-java-sdk-s3-1.12.410.jar /opt/keycloak/providers/aws-java-sdk-s3-1.12.410.jar
ADD --chown=keycloak:keycloak jgroups-aws-2.0.1.Final.jar /opt/keycloak/providers/jgroups-aws-2.0.1.Final.jar
ADD --chown=keycloak:keycloak joda-time-2.12.2.jar /opt/keycloak/providers/joda-time-2.12.2.jar
ADD --chown=keycloak:keycloak dasniko.keycloak-rest-endpoint.jar /opt/keycloak/providers/joda-time-2.12.2.jar

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]