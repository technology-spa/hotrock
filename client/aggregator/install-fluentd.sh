# Fetch and exec main installer
curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.5.sh | sh

# Permit lower port bindings to td-agent ruby executable
sudo setcap 'cap_net_bind_service=+ep' /opt/td-agent/embedded/bin/ruby

# Install FluentD plugins
/usr/sbin/td-agent-gem install out_secure_forward
/usr/sbin/td-agent-gem install fluent-plugin-grep
/usr/sbin/td-agent-gem install fluent-plugin-secure-forward

# Pull latest config
# -- need to pull from secure S3 location

# Resart service to implement latest changes 
systemctl restart td-agent


