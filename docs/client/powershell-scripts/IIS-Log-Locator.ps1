### This Script identifies unique IIS log locations and column patterns and outputs them to a shared location.
###uses Get-Website to locate IIS logs 

$servers = @("") 

foreach ($server in $servers){

    $script =
    {
    Import-Module WebAdministration
    $WebSites = @(Get-Website | Select Name, Id, LogFile)
	$FieldsArray = [System.Collections.ArrayList]@()
    $PathsArray = [System.Collections.ArrayList]@()
    
  
    foreach ($server in $servers){

        $script =
        {
        Import-Module WebAdministration
        $WebSites = @(Get-Website | Select Name, Id, LogFile)
        $FieldsArray = [System.Collections.ArrayList]@()
        $PathsArray = [System.Collections.ArrayList]@()
        Clear-Content "C:\temp\iisfields.txt" -ErrorAction SilentlyContinue
        Clear-Content "C:\temp\iispaths.txt" -ErrorAction SilentlyContinue
      
        foreach ($WebSite in $WebSites){
            
            #Get Web Site Information
            $SiteName = $WebSite.Name
            $SiteID = $WebSite.Id
            # Get Web Site Log Path
            $LogDirectory = $WebSite.LogFile.Directory -Replace '%SystemDrive%', $env:SystemDrive
            $LogPath = $LogDirectory + "\W3SVC" +  $SiteID
            [void]$PathsArray.Add($LogDirectory)
              $LogFiles = Get-ChildItem $LogPath -Filter *.log -EA SilentlyContinue | ? {$_.LastWriteTime -gt (Get-Date).AddDays(-7)} | Sort-Object LastWriteTime -Descending
            # Get the Fields Line from IIS Log if it exists 
            if ($LogFiles) { $LogFilePath = $LogFiles[0].FullName; $W3SVCField = Select-String -Path $LogFilePath -Pattern '^#Fields' -list | Select-Object -First 1}
            
            [void]$FieldsArray.Add($W3SVCField.Line)
    
            $LogDirectory = $WebSite.LogFile.Directory -Replace '%SystemDrive%', $env:SystemDrive
            $LogPath = $LogDirectory + "\SMTPSVC" +  $SiteID
            [void]$PathsArray.Add($LogDirectory)
            $LogFiles = Get-ChildItem $LogPath -Filter *.log -EA SilentlyContinue | ? {$_.LastWriteTime -gt (Get-Date).AddDays(-7)} | Sort-Object LastWriteTime -Descending 
            # Get the Fields Line from IIS Log if it exists 
            if ($LogFiles) { $LogFilePath = $LogFiles[0].FullName; $SMTPSVCField = Select-String -Path $LogFilePath -Pattern '^#Fields' -list | Select-Object -First 1}
            [void]$FieldsArray.add($SMTPSVCField.Line)
    
           }
    
            $FieldsFile = "C:\temp\iisfields.txt"
            $UniqueFields = $FieldsArray | Sort-Object | Get-Unique
            Add-Content $FieldsFile $UniqueFields
    
            $PathsFile = "C:\temp\iispaths.txt"
            $UniquePaths = $PathsArray | Sort-Object | Get-Unique
            Add-Content $PathsFile $UniquePaths
    
                }
    Invoke-Command -ComputerName $server -ScriptBlock $script
	
    $ServerFields = Get-Content "\\$server\c$\temp\iisfields.txt" | Get-Unique
    $AllFields = "\\SHARE\Filebeat\iisfields.txt"
    Add-Content -Value $ServerFields -Path $AllFields

    $ServerPaths = Get-Content "\\$server\c$\temp\iispaths.txt" | Get-Unique
    $AllPaths = "\\SHARE\Filebeat\iispaths.txt"
    Add-Content -Value $ServerPaths -Path $AllPaths
  }
}
}
$FinalFields = Get-Content \\SHARE\Filebeat\iisfields.txt | Sort-Object| Get-Unique
$FinalFields
   