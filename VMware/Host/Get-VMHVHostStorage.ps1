#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Retrieves the host storages on a vCenter Server system

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
        [sr-en] Host for which you want to retrieve storage information
        [sr-de] Hostname

    .Parameter Id
        [sr-en] ID of the host storages that you want to retrieve
        [sr-de] Id des Host
        
    .Parameter Refresh  
        [sr-en] Refreshes the storage system information before retrieving the specified host storages
        [sr-de] Informationen zuvor aktualisieren

    .Parameter RescanAllHba  
        [sr-en] Rescan all virtual machine hosts bus adapters for new storage devices prior to retrieving the storage information
        [sr-de] Host-Bus-Adapter der virtuellen Maschine zuvor aktualisieren

    .Parameter RescanVmfs  
        [sr-en] Re-scan for new virtual machine file systems 
        [sr-de] Dateisysteme zuvor aktualisieren
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$HostName,
    [string]$Id,
    [switch]$Refresh,
    [switch]$RescanAllHba,
    [switch]$RescanVmfs
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if([System.String]::IsNullOrWhiteSpace($Id) -eq $true){
        $Script:Output = Get-VmHostStorage -Server $Script:vmServer -VMHost $HostName -Refresh:$Refresh `
                            -RescanAllHba:$RescanAllHba -RescanVmfs:$RescanVmfs -ErrorAction Stop | Select-Object *   
    }
    else {
        $Script:Output = Get-VmHostStorage -Server $Script:vmServer -ID $Id -ErrorAction Stop | Select-Object *          
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