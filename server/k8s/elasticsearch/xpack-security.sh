#!/bin/bash

# https://www.elastic.co/guide/en/elasticsearch/reference/7.2/certutil.html

export STACK_VERSION='7.2.0'
# if using multiple namespaces, prefer setting a FQDN for the hostname as shown
export CERTIFICATE_HOSTNAME='hotrock-es-master'
export CERTIFICATE_SAN='hotrock-es-master.default.svc.cluster.local'  # comma-separated for > 1 value

# elasticsearch
docker rm -f elastic-helm-charts-certs || true
rm -f elastic-certificates.p12 elastic-certificate.pem elastic-stack-ca.p12 || true
password=$([ ! -z "$ELASTIC_PASSWORD" ] && echo $ELASTIC_PASSWORD || echo $(docker run --rm docker.elastic.co/elasticsearch/elasticsearch:$STACK_VERSION /bin/sh -c "< /dev/urandom tr -cd '[:alnum:]' | head -c50")) && \
docker run --name elastic-helm-charts-certs -i -w /app \
  docker.elastic.co/elasticsearch/elasticsearch:$STACK_VERSION \
  /bin/sh -c " \
    elasticsearch-certutil ca --out /app/elastic-stack-ca.p12 --pass '' && \
    elasticsearch-certutil cert --name $CERTIFICATE_HOSTNAME --dns $CERTIFICATE_SAN --ca /app/elastic-stack-ca.p12 --pass '' --ca-pass '' --out /app/elastic-certificates.p12" && \
docker cp elastic-helm-charts-certs:/app/elastic-certificates.p12 ./ && \
docker rm -f elastic-helm-charts-certs && \
openssl pkcs12 -nodes -passin pass:'' -in elastic-certificates.p12 -out elastic-certificate.pem ; \
kubectl create secret generic hotrock-es-certificates --from-file=elastic-certificates.p12 ; \
kubectl create secret generic hotrock-es-certificate-pem --from-file=elastic-certificate.pem ; \
kubectl create secret generic hotrock-es-credentials  --from-literal=ELASTICSEARCH_PASSWORD=$password --from-literal=ELASTICSEARCH_USERNAME=elastic ; \
rm -f elastic-certificates.p12 elastic-certificate.pem elastic-stack-ca.p12

# kibana
encryptionkey=$(echo $(docker run --rm docker.elastic.co/elasticsearch/elasticsearch:$STACK_VERSION /bin/sh -c "< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c50"))
kubectl create secret generic hotrock-kibana-encryption --from-literal=encryptionkey=$encryptionkey
