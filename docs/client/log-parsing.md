# Log Parsing with Fluentd 
Fluentd has a number of [parser plugins](https://docs.fluentd.org/parser) to break down log files into fields to be processed in Elasticsearch. 

Winlogbeat and Wazuh do not need any additional parsing. 
The majority of logs collected in Filebeat will. 
Additional log streams such as Cisco ASA logs and MCAS Siem Agent will also need parsing. 
Some examples are provided in the config folder. 

## Parsing in Hotrock 

All parsing is included in the **ingestor** fluent.conf. 
Files can be included in fluent.conf using an @include statement. 

```
@include example.conf
```

## Finding and Parsing IIS Logs
The current solution is not as automated as we would like, but gets the job done. Long term goal is to implement a feature that autodetects IIS locations and parsing patterns. 

IIS logs do not have a standard location and can vary between servers. 
They can also have custom column formats. 

os.windows.conf shows an example of how to set up a parser that will parse all variants in your system

To simplify this, IIS-Log-Locator.ps1 will determine unique logpaths and #Fields

### IIS-Log-Locator.ps1
 - Runs over an array of servers 
 - Pulls two pieces of information 
	 - Path to the folder which contains W3SVC*/SMTPVC log folders for filebeat config
	 - the "#Fields" line which provides the format of the log file 
- Saves a list of unique values to a shared network location 
- A regex pattern can be written from this fields list. The default parsing pattern should have the regex for each individual column

Default IIS Fields: 
\#Fields Date, Time, ClientIP, UserName, ServerIP, Method, UriStem, UriQuery, TimeTaken, HttpStatus, Win32Status, ServerPort, UserAgent, HttpSubStatus, and Referer.

Default IIS Regex: 

    /(?<time>[\d]{4}-[\d]{2}-[\d]{2} [\d]{2}:[\d]{2}:[\d]{2}) (?<c-ip>\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b) (?<username>\S+) (?<s-ip>\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)  (?<method>\w+|-) (?<uri-stem>\S*) (?<uri-query>\S*) (?<time-taken>\d+|-) (?<status>\d+|-) (?<win32-status>\d+|-) (?<s-port>\d+) (?<bytes-sent>\d+|-) (?<bytes-received>\d+|-) (?<time-taken>\d+|-) (?<user-agent>[\S]*) (?<substatus>\d+|-) (?<referrer>[\S]*)/
