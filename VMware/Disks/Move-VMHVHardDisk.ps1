#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Moves a hard disk from one location to another

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Disks

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter SourceDatastoreName
        [sr-en] Datastore of the hard disk
        [sr-de] Quell-Datastore

    .Parameter TargetDatastoreName
        [sr-en] Datastore where you want to place the hard disk
        [sr-de] Ziel-Datastore

    .Parameter DiskID
        [sr-en] ID of the hard disk you want to move
        [sr-de] ID der Festplatte

    .Parameter StorageFormat
        [sr-en] Storage format of the relocated hard disk
        [sr-de] Format der Festplatte
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$SourceDatastoreName,    
    [Parameter(Mandatory = $true)]
    [string]$TargetDatastoreName,
    [Parameter(Mandatory = $true)]
    [string]$DiskID,
    [ValidateSet("Thin", "Thick", "EagerZeroedThick")]
    [string]$StorageFormat = "Thick"
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $store = Get-Datastore -Server $Script:vmServer -Name $SourceDatastoreName -ErrorAction Stop
    $Script:harddisk = Get-HardDisk -Server $Script:vmServer -Id $DiskID -Datastore $store -ErrorAction Stop

    $store = Get-Datastore -Server $Script:vmServer -Name $TargetDatastoreName -ErrorAction Stop    
    $Script:Output = Move-HardDisk -Server $Script:vmServer -HardDisk $Script:harddisk -Datastore $store `
                           -StorageFormat $StorageFormat -Confirm:$false -ErrorAction Stop | Select-Object *    

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
    if($null -ne $Script:vmServer) {
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}