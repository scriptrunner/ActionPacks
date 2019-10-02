#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

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
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Datastore

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter Datastore
    Specifies the name of the datastore you want to modify

.Parameter NewName
    Specifies a new name for the datastore

.Parameter CongestionThresholdMillisecond
    Specifies the latency period beyond which the storage array is considered congested

.Parameter EvacuateAutomatically
    Specifies whether you want to automatically migrate all virtual machines to another datastore if the value of MaintenanceMode is $true

.Parameter MaintenanceMode
    Specifies whether you want to put the datastore in maintenance mode

.Parameter StorageIOControlEnabled
    Indicates whether you want to enable the IO control
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

Import-Module VMware.PowerCLI

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