#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Retrieves hosts firmware information

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module VMware.VimAutomation.Core

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter HostName
        [sr-en] Name of the host for which you want to retrieve firmware information
        [sr-de] Hostname
        
    .Parameter BackupConfiguration
        [sr-en] Backup the host firmware configuration and download the bundle to the specified DestinationPath
        [sr-de] Hostfirmware sichern

    .Parameter DestinationPath
        [sr-de] Destination path where to download the host configuration backup bundle if the BackupConfiguration parameter is set
        [sr-en] Download-Pfad der Sicherung
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [switch]$BackupConfiguration,
    [string]$DestinationPath
)

Import-Module VMware.VimAutomation.Core

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    $vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop

    if($BackupConfiguration -eq $true){
        $Script:Output = Get-VMHostFirmware -Server $Script:vmServer -VMHost $vmHost -BackupConfiguration -DestinationPath $DestinationPath -ErrorAction Stop | Select-Object *
    }
    else{
        $Script:Output = Get-VMHostFirmware -Server $Script:vmServer -VMHost $vmHost -ErrorAction Stop | Select-Object *
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Output 
    }
    else{
        Write-Output $Script:Output
    }
}
catch{
    throw
}
finally{    
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}