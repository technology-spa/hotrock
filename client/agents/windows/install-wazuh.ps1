$package_url = "https://packages.wazuh.com/3.x/windows/wazuh-agent-3.8.2-1.msi"
$package_file = "wazuh-agent-latest.msi"
$address = "chip-wz.adatechnologists.com"
$auth_server = "chip-wz.adatechnologists.com"
$auth_password = "xlHKgRnGCdt9Xz8q6eW5cKLBgw0Hhd30A8E39ZHGH5sH8kNU7BcCceVYs46dMMt"
$proto = "TCP"

#fetch installer into current working directory
Invoke-WebRequest -Uri $package_url -OutFile $package_file

#execute silent installation
.\$package_file /q ADDRESS=$address AUTHD_SERVER=$auth_server PROTOCOL=$proto PASSWORD=$auth_password

