# Elasticsearch

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [Elasticsearch](#elasticsearch)   
   - [Install / Upgrade / Delete](#install-upgrade-delete)   
      - [Install](#install)   
      - [Upgrade](#upgrade)   
      - [Delete (DANGER)](#delete-danger)   
   - [CONSOLE](#console)   
      - [GENERAL](#general)   
         - [Get Cluster Health](#get-cluster-health)   
         - [Get Settings](#get-settings)   
         - [Get Node Statistics](#get-node-statistics)   
      - [MONITORING](#monitoring)   
         - [DISK](#disk)   
            - [See Disk Utilization Among Hosts](#see-disk-utilization-among-hosts)   
            - [Show Indices](#show-indices)   

<!-- /MDTOC -->

---

+   [`helm` chart](https://github.com/helm/charts/tree/master/stable/elasticsearch)

## Install / Upgrade / Delete

*Note: It will take a ~5m for ElasticSearch to be ready once installed*

### Install

1.  Install

```bash
helm --debug install --namespace client --name elasticsearch --values './server/k8s/helm/elasticsearch/values.yaml' stable/elasticsearch --version 1.19.1
```

2.  Create Index?

```
PUT /chipper
{
    "settings": {
        "number_of_shards" : 1,
        "number_of_replicas" : 1
    }
}
```

### Upgrade

```bash
helm --debug upgrade --namespace client elasticsearch --values './server/k8s/helm/elasticsearch/values.yaml' stable/elasticsearch --version 1.19.1
```

### Delete (DANGER)

```bash
helm del --purge elasticsearch
```

## CONSOLE

### GENERAL

#### Get Cluster Health

```
GET _cluster/health?pretty
```

#### Get Settings

```
GET _cluster/settings?pretty
```

#### Get Node Statistics

```
GET _nodes/stats
```

### MONITORING

#### DISK

##### See Disk Utilization Among Hosts

```
GET /_cat/allocation?v
```

```
shards disk.indices disk.used disk.avail disk.total disk.percent host      ip        node
    69       23.5gb    26.4gb      2.9gb     29.4gb           89 10.0.0.15 10.0.0.15 elasticsearch-data-0
    69       23.5gb    26.3gb        3gb     29.4gb           89 10.0.2.18 10.0.2.18 elasticsearch-data-1
     3                                                                               UNASSIGNED
```

##### Show Indices

```
GET _cat/indices?v
```
