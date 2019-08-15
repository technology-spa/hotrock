###Function to Install Beat ####
### Requires Powershell v3###

$beat = "winlogbeat" #Which beat is being installed/updated
$location = "C:"    #Install Directory - Omit final "\" e.g. "C:\Beats"
$installVersion = "6.8.0"   #Version to be Installed - e.g "7.0.1" 
$ymlLocation = "C:\temp\$beat.yml" #Use full file path

Function Install-Beat {
		#Set Parameters 
		Param(
		[parameter(Mandatory=$true)]
		[String] $beat,
				
		[parameter(Mandatory=$true)]
		[String] $installVersion,

		[parameter(Mandatory=$true)]
		[String] $location,

		[parameter(Mandatory=$false)]
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
		
		If ($ymlLocation){
		#Copy yml from remote location
		Copy-Item $ymlLocation -Destination "$location\$beat-windows-x86_64\"
		} else {
		}

		#run service install script
		cd "$location\$beat-windows-x86_64"
		& .\install-service-$beat.ps1

		#start service
		Start-Service $beat
		}

If ($ymlLocation) {
Install-Beat -beat $beat -location $location -installVersion $installVersion -ymlLocation $ymlLocation
} else {
Install-Beat -beat $beat -location $location -installVersion $installVersion
}