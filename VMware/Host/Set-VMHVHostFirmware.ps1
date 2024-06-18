#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Configures hosts firmware settings

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
        [sr-en] Name of the host for which you want to modify the firmware informations
        [sr-de] Hostname
        
    .Parameter HostCredential
        [sr-en] Credential object you want to use for authenticating with the host when uploading a firmware configuration bundle
        [sr-de] Benutzerkonto des Hosts
        
    .Parameter SourcePath
        [sr-en] Path to the host configuration backup bundle you want to restore
        [sr-de] Pfad der Backupdatei
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Reset")]
    [Parameter(Mandatory = $true,ParameterSetName = "Restore")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "Reset")]
    [Parameter(Mandatory = $true,ParameterSetName = "Restore")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "Reset")]
    [Parameter(Mandatory = $true,ParameterSetName = "Restore")]
    [string]$HostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Restore")]
    [pscredential]$HostCredential,
    [Parameter(ParameterSetName = "Restore")]
    [string]$SourcePath
)

Import-Module VMware.VimAutomation.Core

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    $Script:vmHost = Get-VMHost -Server $Script:vmServer -Name $Script:HostName -ErrorAction Stop
    Set-VMHost -VMHost $Script:vmHost -State 'Maintenance'

    if($PSCmdlet.ParameterSetName  -eq "Reset"){
        $null = Set-VMHostFirmware -Server $Script:vmServer -VMHost $Script:vmHost -ResetToDefaults -Confirm:$false -ErrorAction Stop
    }
    else {
        $null = Set-VMHostFirmware -Server $Script:vmServer -VMHost $Script:vmHost -Restore -HostCredential $HostCredential -SourcePath $SourcePath -Force:$true -Confirm:$false -ErrorAction Stop
    }
    $result = Get-VMHostFirmware -Server $Script:vmServer -VMHost $Script:vmHost -ErrorAction Stop | Select-Object *

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
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