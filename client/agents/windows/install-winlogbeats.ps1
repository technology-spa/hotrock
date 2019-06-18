$package_url = "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-6.6.0-windows-x86_64.zip"
$package_file = "winlogbeat-windows-x86_64.zip"
$address = "chip-wz.adatechnologists.com"
$auth_server = "chip-wz.adatechnologists.com"
$auth_password = "xlHKgRnGCdt9Xz8q6eW5cKLBgw0Hhd30A8E39ZHGH5sH8kNU7BcCceVYs46dMMt"
$proto = "TCP"

#fetch installer into current working directory
Invoke-WebRequest -Uri $package_url -OutFile $package_file

Expand-Archive -Path $package_file -DestinationPath "C:\Program Files"
Rename-Item "winlogbeat*" "Winlogbeat"

#run service install script
cd 'C:\Program Files\Winlogbeat'
.\install-service-winlogbeat.ps1

