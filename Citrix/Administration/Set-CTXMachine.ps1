#Requires -Version 5.0

<#
    .SYNOPSIS
        Sets properties on a machine
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires the library script CitrixLibrary.ps1
        Requires PSSnapIn Citrix*

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Administration
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter MachineName
        [sr-en] Machine whose properties you want to set (in the form 'domain\machine')
        [sr-de] Name der Maschine (Domäne\Maschinenname)

    .Parameter Uid
        [sr-en] Uid of the machine whose properties you want to set
        [sr-de] UId der Maschine

    .Parameter AssignedClientName
        [sr-en] Client name assignment of the machine
        [sr-de] Zugewiesener Client-Name

    .Parameter AssignedIPAddress
        [sr-en] Client address assignment of the machine
        [sr-de] Zugewiesen Client-IP-Adresse

    .Parameter HostedMachineId
        [sr-en] Unique ID by which the hypervisor recognizes the machine
        [sr-de] Eindeutige ID der Maschine beim Hypervisor

    .Parameter HypervisorConnectionUid
        [sr-en] Hypervisor connection that runs the machine
        [sr-de] Hypervisor-Verbindung, auf der die Maschine läuft

    .Parameter InMaintenanceMode
        [sr-en] Maintenance mode of the machine
        [sr-de] Wartungsmodus der Maschine

    .Parameter IsReserved
        [sr-en] Machine should be reserved for special use
        [sr-de] Maschine wird für spezielle Verwendung reserviert 

    .Parameter PublishedName
        [sr-en] Name of the machine that is displayed in StoreFront, if the machine has been published
        [sr-de] Anzeigename der Maschine in StoreFront
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = 'byName')]
    [string]$MachineName,
    [Parameter(Mandatory = $true,ParameterSetName = 'byID')]
    [Int64]$Uid,
    [Parameter(ParameterSetName = 'byName')]
    [Parameter(ParameterSetName = 'byID')]
    [string]$AssignedClientName,
    [Parameter(ParameterSetName = 'byName')]
    [Parameter(ParameterSetName = 'byID')]
    [string]$AssignedIPAddress,
    [Parameter(ParameterSetName = 'byName')]
    [Parameter(ParameterSetName = 'byID')]
    [string]$HostedMachineId,
    [Parameter(ParameterSetName = 'byName')]
    [Parameter(ParameterSetName = 'byID')]
    [int]$HypervisorConnectionUid,
    [Parameter(ParameterSetName = 'byName')]
    [Parameter(ParameterSetName = 'byID')]
    [bool]$InMaintenanceMode,
    [Parameter(ParameterSetName = 'byName')]
    [Parameter(ParameterSetName = 'byID')]
    [bool]$IsReserved,
    [Parameter(ParameterSetName = 'byName')]
    [Parameter(ParameterSetName = 'byID')]
    [string]$PublishedName,
    [Parameter(ParameterSetName = 'byName')]
    [Parameter(ParameterSetName = 'byID')]
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('MachineName','PowerState','FaultState','MaintenanceModeReason','SessionCount','SessionState','CatalogName','DesktopGroupName','IPAddress','ZoneName','Uid','SessionsEstablished','SessionsPending')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            }

    if($PSCmdlet.ParameterSetName -eq 'byID'){
        $cmdArgs.Add('Uid',$Uid)
    }
    else{
        $cmdArgs.Add('MachineName',$MachineName)
    }
    $machine = Get-BrokerMachine @cmdArgs

    StartLogging -ServerAddress $SiteServer -LogText "Update machine $($machine.MachineName)" -LoggingID ([ref]$LogID)

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'AdminAddress' = $SiteServer
                'InputObject' = $machine
                'PassThru' = $null
                'LoggingID' = $LogID
                }        
    
    if($PSBoundParameters.ContainsKey('AssignedClientName') -eq $true){
        $cmdArgs.Add('AssignedClientName',$AssignedClientName)
    }
    if($PSBoundParameters.ContainsKey('AssignedIPAddress') -eq $true){
        $cmdArgs.Add('AssignedIPAddress',$AssignedIPAddress)
    }
    if($PSBoundParameters.ContainsKey('HostedMachineId') -eq $true){
        $cmdArgs.Add('HostedMachineId',$HostedMachineId)
    }
    if($PSBoundParameters.ContainsKey('InMaintenanceMode') -eq $true){
        $cmdArgs.Add('InMaintenanceMode',$InMaintenanceMode)
    }
    if($PSBoundParameters.ContainsKey('HypervisorConnectionUid') -eq $true){
        $cmdArgs.Add('HypervisorConnectionUid',$HypervisorConnectionUid)
    }
    if($PSBoundParameters.ContainsKey('IsReserved') -eq $true){
        $cmdArgs.Add('IsReserved',$IsReserved)
    }
    if($PSBoundParameters.ContainsKey('PublishedName') -eq $true){
        $cmdArgs.Add('PublishedName',$PublishedName)
    }

    $ret = Set-BrokerMachine @cmdArgs | Select-Object $Properties
    $success = $true
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}