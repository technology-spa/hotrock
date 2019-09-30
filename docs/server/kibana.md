# Kibana

- [Kibana](#kibana)
  - [Custom Docker Image (Optional)](#custom-docker-image-optional)
  - [Install / Upgrade](#install--upgrade)
  - [Create Index Patterns Via API](#create-index-patterns-via-api)
    - [FluentD](#fluentd)
    - [Optional](#optional)
      - [AWS Lambda](#aws-lambda)
      - [Microsoft's SIEM Agent](#microsofts-siem-agent)
      - [Wazuh](#wazuh)
    - [Timelion](#timelion)

## Custom Docker Image (Optional)

For adding the **Wazuh** plugin or for other reasons, create and host a custom Docker image including plugins and pre-optimization (change as needed):

```bash
export KIBANA_DOCKER_TAG='v7.2.1-0' DOCKER_REPO_NAME='' DOCKER_REPO_ADDRESS='' && \
eval $(aws ecr get-login --no-include-email) && \
docker build -t $DOCKER_REPO_ADDRESS/$DOCKER_REPO_NAME/kibana:$KIBANA_DOCKER_TAG ./server/k8s/kibana/ && \
docker push $DOCKER_REPO_ADDRESS/$DOCKER_REPO_NAME/kibana:$KIBANA_DOCKER_TAG && \
unset KIBANA_DOCKER_TAG DOCKER_REPO_NAME DOCKER_REPO_ADDRESS
```

## Install / Upgrade

+ If you're using **Wazuh**, set `plugins.enabled` to `true`. The **Wazuh** plugin will create index patterns and templates.

Create the secret containing the username/password for Kibana's service account:

```bash
kubectl apply -f './server/k8s/kibana/kibana-secrets.yaml'
```

```bash
# install
helm install --name hotrock-kibana --values './server/k8s/kibana/kibana.yaml' elastic/kibana --version 7.2.1-0
# upgrade
helm upgrade hotrock-kibana --values './server/k8s/kibana/kibana.yaml' elastic/kibana --version 7.2.1-0
# delete
helm del --purge hotrock-kibana
```

Get kibana health:

```bash
curl -ks -X GET "https://${HOTROCK_ES_AUTH}@${HOTROCK_KB_SVC}:5601/api/status" -H 'kbn-xsrf: true' | jq
```

Execute the following steps internally via the **toolshed** pod.

## Create Index Patterns Via API

*This can also be done in **Kibana**'s Management pane*

### FluentD

```bash
curl -ks -X POST "https://${HOTROCK_ES_AUTH}@${HOTROCK_KB_SVC}:5601/api/saved_objects/index-pattern/hotrock.fluentd-*" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "attributes": {
     "title": "hotrock.fluentd-*",
     "timeFieldName": "@timestamp"
  }
}' | jq
```

### Optional

#### AWS Lambda

```bash
curl -ks -X POST "https://${HOTROCK_ES_AUTH}@${HOTROCK_KB_SVC}:5601/api/saved_objects/index-pattern/hotrock.aws-*" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "attributes": {
     "title": "hotrock.aws-*",
     "timeFieldName": "@timestamp"
  }
}' | jq
```

#### Microsoft's SIEM Agent

```bash
curl -ks -X POST "https://${HOTROCK_ES_AUTH}@${HOTROCK_KB_SVC}:5601/api/saved_objects/index-pattern/hotrock.mcas_siemagent-*" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "attributes": {
     "title": "hotrock.mcas_siemagent-*",
     "timeFieldName": "@timestamp"
  }
}' | jq
```

#### Wazuh

+ [Wazuh Template JSON](https://github.com/wazuh/wazuh/blob/master/extensions/elasticsearch/7.x/wazuh-template.json)

This should be taken care of by the **Wazuh** **Kibana** App at startup, but if you encounter errors relating to elasticsearch templates, run:

```bash
curl -s https://raw.githubusercontent.com/wazuh/wazuh/3.9/extensions/elasticsearch/7.x/wazuh-template.json | curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_template/wazuh" -H 'Content-Type: application/json' -d @- | jq
```

as well as this one:

```bash
curl -ks -X POST "https://${HOTROCK_ES_AUTH}@${HOTROCK_KB_SVC}:5601/api/saved_objects/index-pattern/wazuh-alerts-3.x-*" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "attributes": {
     "title": "wazuh-alerts-3.x-*",
     "timeFieldName": "@timestamp"
  }
}' | jq
```

#Getting Started with Kibana
There is a great deal of documentation out there on how to best utilize Kibana. Below, I've included links to a few videos/docs to help you get started making visualizations and dashboards. 

##General
[Kibana Documentation](https://www.elastic.co/guide/en/kibana/current/introduction.html)
[Organizing Kibana with Spaces](https://www.youtube.com/watch?v=BqvrL8j_TKI&list=PLhLSfisesZItMosBx0csZGld0n2htxXMO&index=2)


##Visualization
[Visualization Basics](https://www.elastic.co/guide/en/kibana/current/tutorial-visualizing.html)
[Understanding Kibana Aggregations](https://www.youtube.com/watch?v=j-eCKDhj-Os)

### Timelion
Timelion is a graphing alternative within Kibana that can be used to run more complex operations than are generally found in the other graphs. Please see the short video below from Elastic on getting started with it. 
[Timelion: Time Series Analytics for Kibana](https://www.youtube.com/watch?v=-sgZdW5k7eQ)