$servers= @(
    )

foreach ($server in $servers){
    $script =
    {
	$package_url = "https://packages.wazuh.com/3.x/windows/wazuh-agent-3.9.1-1.msi"
	$package_file = "wazuh-agent-latest.msi"
	$address = "wz.domain.tld""
	$auth_password = 
	$auth_server = "wz.domain.tld"
	$proto = "TCP"
	
    cd C:\temp
	#fetch installer into current working directory
	Invoke-WebRequest -Uri $package_url -OutFile $package_file
    Stop-Service Wazuh 

	#execute silent installation
    
	Start-Process C:\Temp\wazuh-agent-latest.msi -ArgumentList "/q ADDRESS=$address AUTHD_SERVER=$auth_server PROTOCOL=$proto PASSWORD=$auth_password" -wait 
    cd "C:\Program Files (x86)\ossec-agent"
    .\agent-auth -m $auth_server -P $auth_password
	Copy-Item "C:\temp\ossec.conf" "C:\Program Files (x86)\ossec-agent"
	Remove-Item wazuh-agent-latest.msi
	Remove-Item "C:\temp\chipper_file.txt"
	Remove-Item "C:\temp\ossec.conf"
    Start-Service Wazuh
	
    }
   	#If modifications are made to ossec.conf: 
    #Copy-Item –Path "\\prod.hosting\NETLOGON\Chipper\wazuh\ossec.conf" –Destination "\\$server\c$\temp"
    Invoke-Command -ComputerName $server -ScriptBlock $script  
}

