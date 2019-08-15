### Function to Update YML for a Beat and Restart Service ###
### Be sure to back up your old yml before running ###


#Use this Arry for Deploying to a list of Servers
$servers = 
(
)

$beat = "winlogbeat" #Which beat is yml for 
$location = "C:"    #Installed Directory - Omit final "\" e.g. "C:\Beats"
$ymlLocation = "C:\temp\$beat.yml" #If this location is not used the copy item in line 46
$sharedYML = "\\prod.hosting\NETLOGON\Chipper\$beat\$beat.yml" # shared yml location

	Foreach ($server in $servers) {
		#Script that is invoked on each server
		$script =  
			
			{
						   
				#This Function Checks Whether or Not Filebeat is installed 
				Function Update-YML {
					#Set Parameters		
					Param(
					[parameter(Mandatory=$true)]
					[String] $beat,
							
					[parameter(Mandatory=$true)]
					[String] $location,
	
					[parameter(Mandatory=$true)]
					[String] $ymlLocation
					)
					
					
					Stop-Service "$beat"
					Copy-Item –Path $ymlLocation –Destination "$location\$beat-windows-x86_64\$beat.yml"
					Start-Service "$beat"
				   }
				
			
		   Update-YML -beat $using:beat -location $using:location -ymlLocation $using:ymlLocation
			
			}
	#Copy yml to Server and Run script  
	Copy-Item –Path $sharedYML –Destination \\$server\c$\temp\$beat.yml
	Invoke-Command -ComputerName $server -ScriptBlock $script  
	
	}



### Optional Script to Check if Updated and Running###
### Just grabs the first line of YML ###
### e.g. in first line put: 
### ###Updated YYYY.MM.DD
<# 
foreach ($server in $servers){
    $script =
    {
    $using:beat = "filebeat" 
    Get-Content "C:\$beat-windows-x86_64\filebeat.yml" -First 1
    Get-Service filebeat
    }
    Invoke-Command -ComputerName $server -ScriptBlock $script  
}

#> 