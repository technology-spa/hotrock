### Multi-Beat Deployment ####
### Script to Update/Install Beats Across Servers###
### Downloads and Installs/Updates Servers as needed ###
### Replaces stock yml with one from shared location###
<# 

####MAKE SURE YOU FILL IN THE VARIABLES####

This script should work for deploying any Elastic Beat across Windows Systems.


It is currently designed to use a list of servers with the beat.yml in a shared network location 

There are a few variables that need to be filled in below.

Script is composed of 3 functions 
- Check-Beat 
- Install-Beat
- Update-Beat 
The 4 variables immediately below are used as parameters for the functions.

Currently written to only install one beat at a time
#>

$beat = "winlogbeat" #Which beat is being installed/updated
$location = "C:"    #Install Directory - Omit final "\" e.g. "C:\Beats"
$installVersion = "6.8.0"   #Version to be Installed - e.g "7.0.1" 
$ymlLocation = "C:\temp\$beat.yml" #File is copied from network drive to this location on each server

#Use this Arry for Deploying to a list of Servers
$servers= @()
#Network Location of $beat.yml
$sharedYML = "\\yourNetworkDrive\$beat\$beat.yml"

<# 
If you will not be deploying with Server Array:
You may need to find/replace all of the $using. with $, depending on your setup
Be sure to update variables within $script to reflect the four above
#>
	
Foreach ($server in $servers) {

	#Script that is invoked on each server
	$script =  
		{
		#Redefine variables from outside of Invoke
		$beat = $using.beat
		$location = $using.location  
		$installVersion = $using.installVersion 
		$ymlLocation = $using.ymlLocation

		#This Function Checks Whether or Not Filebeat is installed 
		Function Check-Beat {
			#Set Parameters		
			Param(
			[parameter(Mandatory=$true)]
			[String] $beat,
					
			[parameter(Mandatory=$true)]
			[String] $installVersion,

			[parameter(Mandatory=$true)]
			[String] $location,

			[parameter(Mandatory=$true)]
			[String] $ymlLocation
			)
			
			#Build Array to hold list of services
			$Services = @()
			#Select name of all services (both running and stopped) and add to array
			$Services += Get-Service | Select Name
			#Check if $beat is in list of services
			$installed = $Services.Name -contains "$beat"
			
			#If beat is not found, fresh install is performed 
			If ($installed -ne "True"){
				Write-Host "Beat is not currently installed. Installing..."
				Install-Beat -beat $beat -location $location -installVersion $installVersion -ymlLocation $ymlLocation
			#If beat is found, check version installed
			} Else { 
			#Interpret as version number
			$installVersionNum = [system.version]$installVersion

			#Version is pulled from README
			$currentVersion = (Get-Content "$location\$beat-windows-x86_64\README.md" -First 1) -match "[\d \.]{6}"
			#Interpret as version number 
			$currentVersion = [system.version]$Matches[0]
			
			#Check if action is needed 
			If ($currentVersion -eq $installVersionNum){
				Write-Host "Version $currentVersion is already installed"
			} Elseif ($currentVersion -gt $InstallVersionNum){ 
				Write-Host "Version $installVersion is older than currently installed version" 
			#If currentVersion is older, run Update-Beat	
			}Else {
			   Update-Beat -beat $beat -location $location -installVersion $installVersion -ymlLocation $ymlLocation
				}
			}

		Function Install-Beat {
			#Set Parameters 
			Param(
			[parameter(Mandatory=$true)]
			[String] $beat,
					
			[parameter(Mandatory=$true)]
			[String] $installVersion,

			[parameter(Mandatory=$true)]
			[String] $location,

			[parameter(Mandatory=$true)]
			[String] $ymlLocation
			)

			#Set download parameters
			#URL is formed using variables already provided
			$package_url = "https://artifacts.elastic.co/downloads/beats/$beat/$beat-$installVersion-windows-x86_64.zip"
			$package_file = "$location\$beat-windows-x86_64.zip"
			$targetFolder = "$location\"

			#download file using TLS 1.2
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
			Invoke-WebRequest -Uri $package_url -OutFile $package_file
			
			#Unzip File
			[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
			[System.IO.Compression.ZipFile]::ExtractToDirectory($package_file, $targetFolder)

			#Remove Zip
			Remove-Item "$location\$beat-windows-x86_64.zip"

			#Rename unzipped version
			Rename-Item "C:\$beat-$installVersion-windows-x86_64" "C:\$beat-windows-x86_64"

			#Copy yml from remote location
			Copy-Item $ymlLocation -Destination "$location\$beat-windows-x86_64\"

			#run service install script
			cd "$location\$beat-windows-x86_64"
			& .\install-service-$beat.ps1

			#start service
			Start-Service $beat
			}

		Function Update-Beat {
			#Set Parameters
			Param(
			[parameter(Mandatory=$true)]
			[String] $beat,
					
			[parameter(Mandatory=$true)]
			[String] $installVersion,

			[parameter(Mandatory=$true)]
			[String] $location,

			[parameter(Mandatory=$true)]
			[String] $ymlLocation
			)
			#Set download parameters
			$package_url = "https://artifacts.elastic.co/downloads/beats/$beat/$beat-$InstallVersion-windows-x86_64.zip"
			$package_file = "$location\$beat-windows-x86_64.zip"
			$targetFolder = "$location\"

			#download file using TLS 1.2
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
			Invoke-WebRequest -Uri $package_url -OutFile $package_file

			#Unzip File
			[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
			[System.IO.Compression.ZipFile]::ExtractToDirectory($package_file, $targetFolder)

			#Remove Zip
			Remove-Item "$location\$beat-windows-x86_64.zip"
			#Wait for process to stop
			Stop-Service $beat
			Wait-Process $beat

			###### Optional Step to Backup Current Install ######
			#Copy-Item "$location\$beat-windows-x86_64" -Destination "C:\temp" -Recurse -Force

			#Remove Old unzipped version
			Remove-Item "$location\$beat-windows-x86_64" -Force -Recurse

			#Rename new unzipped version
			Rename-Item "$location\$beat-$installVersion-windows-x86_64" "$location\$beat-windows-x86_64"

			#If update with same yml 
			Copy-Item $ymlLocation -Destination "$location\$beat-windows-x86_64\"

			#run service install script
			cd "$location\$beat-windows-x86_64"
			& .\install-service-$beat.ps1

			#start service
			Start-Service "$beat"
			}
			
	#Run Check-Beat on Each Server
	Check-Beat -beat $using:beat -location $using:location -installVersion $using:installVersion -ymlLocation $using:ymlLocation
		}

#Copy Shared YML to each Server 
Copy-Item $sharedYML -Destination "\\$server\c$\temp\"
#Invoke Script on Server
Invoke-Command -ComputerName $server -ScriptBlock $script 
#Remove yml from TMP 
Remove-Item "\\$server\c$\temp\$beat.yml"
}
