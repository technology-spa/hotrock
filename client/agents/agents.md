# Machine-level agents for pushing logs and capturing security events
Agents will be required to collect an appriopriate level of logging detail for any Windows or Linux OS based instance.  Each instance will require two discrete agents, one to stream raw log data from either flat files/directories and binary formats (systemD, EventViewer, etc.) and another agent to perform OSSEC functionality including FIM, security policy auditing, inventory and anomoly detection.

## Logs
+ Linux - Fluent-bit
+ Windows - Winlogbeats

## Security
- https://documentation.wazuh.com/current/installation-guide/packages-list/index.html
+ Linux - Wazuh
+ Windows - Wazuh