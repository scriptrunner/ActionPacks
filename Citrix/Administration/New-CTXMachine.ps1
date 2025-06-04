#Requires -Version 5.0

<#
    .SYNOPSIS
        Adds a machine that can be used to run desktops and applications
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter MachineNames
        [sr-en] Name of the machines to create (in the form 'domain\machine')
        [sr-de] Namen der Maschinen (Domäne\Maschinenname)

    .Parameter MachineName
        [sr-en] Name of the machine to create (in the form 'domain\machine')
        [sr-de] Name der Maschine (Domäne\Maschinenname)

    .Parameter CatalogUid
        [sr-en] Catalog to which this machine will belong
        [sr-de] UId des Maschinenkatalogs, für diese Maschine

    .Parameter AssignedClientName
        [sr-en] Client name to which this machine will be assigned
        [sr-de] Client-Name, dem dieses Gerät zugewiesen wird

    .Parameter AssignedIPAddress
        [sr-en] Client IP address to which this machine will be assigned
        [sr-de] Client-IP-Adresse, der dieses Gerät zugewiesen wird

    .Parameter HostedMachineId
        [sr-en] Unique ID by which the hypervisor recognizes the machine
        [sr-de] Eindeutige ID der Maschine beim Hypervisor

    .Parameter HypervisorConnectionUid
        [sr-en] Hypervisor connection that runs the machine
        [sr-de] Hypervisor-Verbindung, auf der die Maschine läuft

    .Parameter InMaintenanceMode
        [sr-en] Machine is initially in maintenance mode
        [sr-de] Maschine zunächst in den Wartungsmodus versetzen

    .Parameter IsReserved
        [sr-en] Machine should be reserved for special use
        [sr-de] Maschine wird für spezielle Verwendung reserviert 
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = 'Single')]
    [string]$MachineName,
    [Parameter(Mandatory = $true,ParameterSetName = 'Multi')]
    [string[]]$MachineNames,
    [Parameter(Mandatory = $true,ParameterSetName = 'Single')]
    [Parameter(Mandatory = $true,ParameterSetName = 'Multi')]
    [Int64]$CatalogUid,
    [Parameter(ParameterSetName = 'Single')]
    [string]$AssignedClientName,
    [Parameter(ParameterSetName = 'Single')]
    [string]$AssignedIPAddress,
    [Parameter(ParameterSetName = 'Single')]
    [string]$HostedMachineId,
    [Parameter(ParameterSetName = 'Single')]
    [int]$HypervisorConnectionUid,
    [Parameter(ParameterSetName = 'Single')]
    [bool]$InMaintenanceMode,
    [Parameter(ParameterSetName = 'Single')]
    [bool]$IsReserved,
    [Parameter(ParameterSetName = 'Single')]
    [Parameter(ParameterSetName = 'Multi')]
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
[string[]]$ret = @()
try{ 
    [string[]]$Properties = @('MachineName','PowerState','FaultState','MaintenanceModeReason','SessionCount','SessionState','CatalogName','DesktopGroupName','IPAddress','ZoneName','Uid','SessionsEstablished','SessionsPending')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'CatalogUid' = $CatalogUid
                            'LoggingID' = $LogID
                            }        
    
    if($PSCmdlet.ParameterSetName -eq 'Single'){         
        StartLogging -ServerAddress $SiteServer -LogText "Create machine $($MachineName)" -LoggingID ([ref]$LogID)
        $cmdArgs.Add('MachineName' , $MachineName)
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
        $ret += New-BrokerMachine @cmdArgs | Select-Object $Properties
        $success = $true
    }
    else{
        foreach($machine in $MachineNames){
            StartLogging -ServerAddress $SiteServer -LogText "Create machine $($machine)" -LoggingID ([ref]$LogID)
            $ret += New-BrokerMachine @cmdArgs -MachineName $machine | Select-Object $Properties
            $success = $true
            StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
            $LogID = $null
        }
    }

    Write-Output $ret
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}