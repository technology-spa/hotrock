# **Aggregator Set Up** 

## **Aggregator Requirements**

 - Red Hat/ CentOS server within your environment
 - Resource usage will vary depending on how many messages. Suggested to start with:  
	 - 4GB Ram 
	 - 2 Core CPU

## Installation of Fluentd
[Fluentd install documentation](https://docs.fluentd.org/installation) can be found here. 

For Redhat: 

    sudo yum install td-agent

### Required Fluentd Plugins
##### [Beats](https://github.com/repeatedly/fluent-plugin-beats/blob/master/README.md)
```
td-agent-gem install fluent-plugin-beats
```
##### [Multi-Format Parser](https://github.com/repeatedly/fluent-plugin-multi-format-parser)
```
td-agent-gem install fluent-plugin-multi-format-parser
```
##### [Rewrite Tag Filter](https://github.com/fluent/fluent-plugin-rewrite-tag-filter)
```
td-agent-gem install fluent-plugin-rewrite-tag-filter
```

## Aggregator Fluentd Configuration
[Fluentd configuration](https://docs.fluentd.org) will vary based on your setup and log streams. 

The provided [*example Fluentd configuration*](../config/aggregator.td-agent.conf) has the following setup: 

- Data will be collected by Elastic Beats and Syslog
- Beats will ship data to Aggregator on port 5044
- Syslog will ship data to Aggregator on port 514
- Aggregator will encrypt and forward the data to the Ingestor on port 24224
- Read more about FluentD Input Plugins [**here**](https://docs.fluentd.org/input).

### Forwarding Logs to Ingestor

The [out_forward output plugin](https://docs.fluentd.org/output/forward) will be used to forward the data to the Ingestor. 

TLS will need to be enabled in the [in_forward input plugin](https://docs.fluentd.org/input/forward) in Ingestor Fluentd config. 

Example configurations from Fluentd can be found [**here**](https://docs.fluentd.org/plugin-helper-overview/api-plugin-helper-server#configuration-example). 

### General Fluentd Information
The Aggregator utilizes very little of Fluentd's capabilities. 
Parsing, tagging, and other operations will be handled at the Ingestor 

[Fluentd Configuration file](https://docs.fluentd.org/configuration/config-file) can be found at:
> /etc/td-agent/td-agent.conf

Fluentd has a [stdout output plugin](https://docs.fluentd.org/output/stdout) that is useful for testing purposes:
>    <match **> 
>	  		\type stdout
>	 \<match> 
	 
This will send logs to: 
>/var/log/td-agent.log
