#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Modifies the properties of the specified datastore

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Datastore

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter Datastore
        [sr-en] Name of the datastore you want to modify
        [sr-de] Datastore

    .Parameter NewName
        [sr-en] New name for the datastore
        [sr-de] Neuer name des Datastores

    .Parameter CongestionThresholdMillisecond
        [sr-en] Latency period beyond which the storage array is considered congested
        [sr-de] Latenzzeit, ab der das Speicherarray als überlastet gilt

    .Parameter EvacuateAutomatically
        [sr-en] Automatically migrate all virtual machines to another datastore if the value of MaintenanceMode is $true
        [sr-de] Virtuellen Maschinen automatisch migrieren, wenn der Maintenance-Mode aktiv ist

    .Parameter MaintenanceMode
        [sr-en] Put the datastore in maintenance mode
        [sr-de] Maintenance Mode für Datastore

    .Parameter StorageIOControlEnabled
        [sr-en] Enable the IO control
        [sr-de] IO Kontrol aktivieren
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Datastore,
    [string]$NewName,
    [ValidateRange(10,100)]
    [int32]$CongestionThresholdMillisecond,
    [switch]$EvacuateAutomatically,
    [bool]$MaintenanceMode,
    [bool]$StorageIOControlEnabled
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $Script:store = Get-Datastore -Server $Script:vmServer -Refresh:$RefreshFirst -Name $Datastore -ErrorAction Stop
    if($CongestionThresholdMillisecond -gt 0){
        $Script:store = Set-Datastore -Server $Script:vmServer -Datastore $Script:store -CongestionThresholdMillisecond $CongestionThresholdMillisecond -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('EvacuateAutomatically') -eq $true){
        $Script:store = Set-Datastore -Server $Script:vmServer -Datastore $Script:store -EvacuateAutomatically:$EvacuateAutomatically -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('MaintenanceMode') -eq $true){
        $Script:store = Set-Datastore -Server $Script:vmServer -Datastore $Script:store -MaintenanceMode $MaintenanceMode -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('StorageIOControlEnabled') -eq $true){
        $Script:store = Set-Datastore -Server $Script:vmServer -Datastore $Script:store -StorageIOControlEnabled $StorageIOControlEnabled -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('NewName') -eq $true){
        $Script:store = Set-Datastore -Server $Script:vmServer -Datastore $Script:store -Name $NewName -Confirm:$false -ErrorAction Stop
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:store | Select-Object *
    }
    else{
        Write-Output $Script:store | Select-Object *
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