# https://hub.docker.com/_/java?tab=tags
FROM openjdk:8u212-jre-slim
WORKDIR /
COPY mcas-siemagent-0.111.126-signed.jar mcas-siemagent-0.111.126-signed.jar
ENTRYPOINT ["java"]
# this is overridden by k8s. But if mis-configured, it'll fallback to printing version and exiting
CMD ["-jar", "/mcas-siemagent-0.111.126-signed.jar", "--version"]
