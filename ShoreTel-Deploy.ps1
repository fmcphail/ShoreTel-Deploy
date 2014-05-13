#You will need to run this in a PowerShell session that has been started with elevated privileges
#Original code taken from https://github.com/dalderman/ShoreTel-Deploy

#Warning running this will reboot your server


#Import the required modules
Import-module servermanager

#Starting point of our custom functions
#Functions borrowed from stackoverflow.com
#http://stackoverflow.com/questions/9572248/how-do-i-disable-uac-using-windows-powershell

Function Test-RegistryValue 
{
    param(
        [Alias("RegistryPath")]
        [Parameter(Position = 0)]
        [String]$Path
        ,
        [Alias("KeyName")]
        [Parameter(Position = 1)]
        [String]$Name
    )

    process 
    {
        if (Test-Path $Path) 
        {
            $Key = Get-Item -LiteralPath $Path
            if ($Key.GetValue($Name, $null) -ne $null)
            {
                if ($PassThru)
                {
                    Get-ItemProperty $Path $Name
                }       
                else
                {
                    $true
                }
            }
            else
            {
                $false
            }
        }
        else
        {
            $false
        }
    }
}

Function Disable-UAC
{
    $EnableUACRegistryPath = "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    $EnableUACRegistryKeyName = "EnableLUA"
    $UACKeyExists = Test-RegistryValue -RegistryPath $EnableUACRegistryPath -KeyName $EnableUACRegistryKeyName 
    if ($UACKeyExists)
    {
        Set-ItemProperty -Path $EnableUACRegistryPath -Name $EnableUACRegistryKeyName -Value 0
    }
    else
    {
        New-ItemProperty -Path $EnableUACRegistryPath -Name $EnableUACRegistryKeyName -Value 0 -PropertyType "DWord"
    }
}

#End of our custom functions

#Lets disable UAC (We'll reboot at the end)
Disable-UAC

#Disable DEP
bcdedit /set nx AlwaysOff

#Adding needed Windows features
Add-WindowsFeature Application-Server     
Add-WindowsFeature AS-NET-Framework       
Add-WindowsFeature AS-Web-Support         
Add-WindowsFeature AS-WAS-Support         
Add-WindowsFeature AS-HTTP-Activation     
Add-WindowsFeature Web-Server             
Add-WindowsFeature Web-WebServer
Add-WindowsFeature Web-Common-Http
Add-WindowsFeature Web-Static-Content
Add-WindowsFeature Web-Default-Doc
Add-WindowsFeature Web-Dir-Browsing
Add-WindowsFeature Web-Http-Errors
Add-WindowsFeature Web-Http-Redirect
Add-WindowsFeature Web-DAV-Publishing
Add-WindowsFeature Web-App-Dev
Add-WindowsFeature Web-Asp-Net
Add-WindowsFeature Web-Net-Ext
Add-WindowsFeature Web-ASP
Add-WindowsFeature Web-CGI
Add-WindowsFeature Web-ISAPI-Ext
Add-WindowsFeature Web-ISAPI-Filter
Add-WindowsFeature Web-Includes
Add-WindowsFeature Web-Health
Add-WindowsFeature Web-Http-Logging
Add-WindowsFeature Web-Log-Libraries
Add-WindowsFeature Web-Request-Monitor
Add-WindowsFeature Web-Http-Tracing
Add-WindowsFeature Web-ODBC-Logging
Add-WindowsFeature Web-Security
Add-WindowsFeature Web-Basic-Auth
Add-WindowsFeature Web-Windows-Auth
Add-WindowsFeature Web-Digest-Auth
Add-WindowsFeature Web-Client-Auth
Add-WindowsFeature Web-Cert-Auth
Add-WindowsFeature Web-Url-Auth
Add-WindowsFeature Web-Filtering
Add-WindowsFeature Web-IP-Security
Add-WindowsFeature Web-Performance
Add-WindowsFeature Web-Stat-Compression
Add-WindowsFeature Web-Dyn-Compression
Add-WindowsFeature Web-Mgmt-Tools
Add-WindowsFeature Web-Mgmt-Console
Add-WindowsFeature Web-Scripting-Tools
Add-WindowsFeature Web-Mgmt-Service
Add-WindowsFeature Web-Mgmt-Compat
Add-WindowsFeature Web-Metabase
Add-WindowsFeature Web-WMI
Add-WindowsFeature Web-Lgcy-Scripting
Add-WindowsFeature Web-Lgcy-Mgmt-Console
Add-WindowsFeature Web-Ftp-Server
Add-WindowsFeature Web-Ftp-Service
Add-WindowsFeature Web-Ftp-Ext
Add-WindowsFeature NET-Framework
Add-WindowsFeature NET-Framework-Core
Add-WindowsFeature NET-Win-CFAC
Add-WindowsFeature NET-HTTP-Activation
Add-WindowsFeature SMTP-Server
Add-WindowsFeature SNMP-Services
Add-WindowsFeature SNMP-Service
Add-WindowsFeature SNMP-WMI-Provider
Add-WindowsFeature Telnet-Client
Add-WindowsFeature WAS
Add-WindowsFeature WAS-Process-Model
Add-WindowsFeature WAS-NET-Environment
Add-WindowsFeature WAS-Config-APIs
Add-WindowsFeature AS-Ent-Services
Add-WindowsFeature AS-Dist-Transaction

#Change services
Set-Service MpsSvc -StartupType disabled
Set-Service wuauserv -StartupType disabled
Set-Service SMTPSVC -StartupType Automatic

#Lets reboot the computer
Restart-Computer -Force -Confirm:$false
