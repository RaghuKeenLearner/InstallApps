#Variables and Information
#Author - Raghu Sharma
#Copies content from remote server over UNC to local machine. Disables UAC -> Run the installer and install app silently -> Enables UAC -> Removes copied data
#Troubleshooting -> 
#Run Enable-PSRemoting -Force on remote machine to make sure PSRemoting is enabled
#If this script is not working. Make sure you run "Set-ExecutionPolicy Bypass -Force" on your computer and remote computer as well, just to be on safer side.
##########################
$computername = Get-Content C:\temp\machinename.txt
$Chrome = "\\Server\Folder\GoogleChromeStandaloneEnterprise64.msi"
$7zip = "\\Server\Folder\7z1900-x64.msi"
$AdobeReader = "\\Server\Folder\1902120058\"

#This section will install the software 
foreach ($computer in $computername) 
{
    $destinationFolder = "\\$computer\C$\Temp\Z_Software_Z"
    
    #It will copy $sourcefile to the $destinationfolder. If the Folder does not exist it will create it.

    if (!(Test-Path -path $destinationFolder))
    {
        New-Item $destinationFolder -Type Directory
    }
   Copy-Item -Path $Chrome -Recurse -Destination $destinationFolder -WarningAction SilentlyContinue -Force -ErrorAction Continue
   Copy-Item -Path $7zip -Recurse -Destination $destinationFolder -WarningAction SilentlyContinue -Force -ErrorAction Continue
   Copy-Item -Path $AdobeReader -Recurse -Destination $destinationFolder -WarningAction SilentlyContinue -Force -ErrorAction Continue

   Start-Sleep 10
   #Disabling UAC here
   Invoke-Command -ComputerName $computer -ScriptBlock {Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0 -Force}
   #Starting to Install applications
   #GoogleChrome
   Invoke-Command -ComputerName $computer -ScriptBlock {Start-Process "C:\temp\Z_Software_Z\GoogleChromeStandaloneEnterprise64.msi" /qn -Wait}
   Start-Sleep 10
   #7-zip
   Invoke-Command -ComputerName $computer -ScriptBlock {Start-Process "C:\temp\Z_Software_Z\7z1900-x64.msi" /qn -Wait}
   Start-Sleep 10
   Start-Sleep 10
   #Adobe Reader 
   Invoke-Command -ComputerName $computer -ScriptBlock {Start-Process "C:\temp\Z_Software_Z\1902120058\setup.exe" -Wait}
   Start-Sleep 10
   #Re-enabling UAC
   Invoke-Command -ComputerName $computer -ScriptBlock {Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 5 -Force}
   
   #Cleaning copied files
   Invoke-Command -ComputerName $computer -ScriptBlock {Remove-Item "C:\temp\Z_Software_Z\" -Recurse -Force}
   }