# Windows Elastic Beat Installation/Configuration
Powershell Scripts provided in **docs/client/powershell** will assist in this process. These scripts should work for any beat. We will specifically be referencing: 
 - Winlogbeat
 - Filebeat
 - Auditbeat

## Installing Beats on Windows
Open Install-Beat.ps1 as an administrator to install a beat on single machine for initial testing
The script will download install the version of whichever beat you specify. 
Modify the following variables in the script before running: 

> $beat = "winlogbeat" #Which beat is being installed/updated

> $location = "C:"    #Install Directory - Omit final "\" e.g. "C:\Beats"

> $installVersion = "6.8.0"   #Version to be Installed - e.g "7.0.1" 

## Manually Load Beat Template into Elasticsearch 
Since we are connecting to Fluentd, the template will need to be loaded manually. [Here is the Elastic documenation showing how to do this](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-template.html#load-template-manually-alternate).] Scattered throughout this template are some settings that we have modified for our configuration. These may differ based on your needs.

For Index Patterns, we are using the format "beat-windows.$beatprefix". e.g. "beat-windows.audit*". 

For our purposes, we have decided on this shard allocation and refresh interval. 
> "number_of_shards" : "3",
> "number_of_replicas" : "2",
> "refresh_interval": "30s" 


## Winlogbeat and Auditbeat Configuration
Navigate to directory where winlogbeat is installed 
Open winlogbeat.yml 
Add Aggregator IP and change to Port 5044. We have additionally added a tag which we will reference in our Fluentd config to make sure it routes correctly. 

```yaml
output.elasticsearch:
   # Array of hosts to connect to.
   hosts: ["localhost:5044"]
   tags: [winlog]
```

Restart winlogbeat

>   `Restart-Service winlogbeat`

This is all the configuration needed for a basic winlogbeat or auditbeat deployment
For more information on configuration, see the [Winlogbeat Docs](https://www.elastic.co/guide/en/beats/winlogbeat/current/configuration-winlogbeat-options.html)

*If both Aggregator and Ingestor have been configured, this data should begin flowing into Kibana*. 

## Filebeat Configuration
Filebeat configuration is highly variable and dependent on file path locations. 
- Please see provided filebeat.yml template with comments. 
	-  For more information on configuration, see the  [Filebeat Docs](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-filebeat-options.html)

[filebeat.yml](../config/filebeat.yml) and [os.windows.conf](../config/os.windows.conf) in the config folder show an example of how to tag log streams in Filebeat for parsing in fluentd. 

## Deploying/Managing Beats across your Windows environment
Multi-Beat-Deploy.ps1 will verify if the specified beat is installed and update to date based on the following variables: 
 1. Open Multi-Beat-Deploy.ps1 in Powershell ISE with admin privileges 
 2. Fill in the specified variables per comments
 3. Provide list of servers to have beat installed on
 4. Run Powershell script 
 
## Updating Beats yaml on Windows 
Script Update-Beat-YML.ps1 can be used to update the config file on every server. 

## Installing/Configuring Beats on Linux 
On indivdual servers, [Beats can be installed using yum, apt-get, and homebrew](https://www.elastic.co/downloads/beats/filebeat. 
[Ansible-Beats](https://github.com/elastic/ansible-beats) can be used to install beats across Linux environments. 

Fluentd has a [syslog parser plugin](https://docs.fluentd.org/parser/syslog). The example Windows filebeat.yml and os.windows.conf shows how tagging can be used to direct specific logstreams to a parser. 