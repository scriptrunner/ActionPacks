#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets one or more reboot cycles
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Applications
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Uid	
        [sr-en] Reboot cycle that have the specified Uid
        [sr-de] Neustart-Zyklus mit diese UId

    .Parameter CatalogUid	
        [sr-en] Gets reboot cycles that relate to the catalog with a particular Uid
        [sr-de] Neustart-Zyklen aus diesem Katalog

    .Parameter RebootDuration	
        [sr-en] Reboot cycles with the specified duration
        [sr-de] Neustart-Zyklen mit der angegebenen Dauer

    .Parameter RestrictToTag	
        [sr-en] Reboot cycles with the specified tag
        [sr-de] Neustart-Zyklen mit dem angegebenen Tag

    .Parameter MachinesCompleted	
        [sr-en] Reboot cycles that have the specified count of machines successfully rebooted during the cycle
        [sr-de] Neustart-Zyklen, bei denen die angegebene Anzahl von Rechnern während des Zyklus erfolgreich neu gestartet wurde

    .Parameter MachinesFailed	
        [sr-en] Reboot cycles that have the specified count of machines issued with reboot requests where either the request failed or the operation did not complete within the allowed time
        [sr-de] Neustart-Zyklen, bei denen die angegebene Anzahl von fehlerhaften Rechnern während des Zyklus

    .Parameter MachinesInProgress	
        [sr-en] Reboot cycles that have the specified count of machines issued with reboot requests but which have not yet completed the operation
        [sr-de] Neustart-Zyklen, bei denen die angegebene Anzahl von Rechner, die eine Aufforderung zum Neustart erhalten, den Vorgang aber noch nicht abgeschlossen haben

    .Parameter MachinesPending	
        [sr-en] Reboot cycles that have the specified count of outstanding machines to be rebooted during the cycle but on which processing has not yet started
        [sr-de] Neustart-Zyklen, bei denen die angegebene Anzahl von Rechner, die während des Zyklus neu gestartet werden sollen, auf denen die Verarbeitung aber noch nicht begonnen hat

    .Parameter MachinesSkipped	
        [sr-en] Reboot cycles that have the specified count of machines scheduled for reboot during the cycle but which were not processed either because the cycle was canceled or abandoned or because the machine was unavailable for reboot processing throughout the cycle
        [sr-de] Neustart-Zyklen, bei denen die angegebene Anzahl von Rechnern während des Zyklus der Neustart abgebrochen wurde

    .Parameter IgnoreMaintenanceMode	
        [sr-en] Reboot machines in maintenance mode
        [sr-de] Neustart von Maschinen im Wartungsmodus

    .Parameter RebootScheduleName	
        [sr-en] Reboot cycles which were triggered by the named reboot schedule
        [sr-de] Reboot-Zyklen, die durch den genannten Reboot-Zeitplan ausgelöst wurden
#>

param( 
    [string]$Uid,
    [string]$CatalogUid,
    [string]$RebootScheduleName,
    [bool]$IgnoreMaintenanceMode,
    [int]$RebootDuration,
    [string]$RestrictToTag,
    [int]$MachinesCompleted,
    [int]$MachinesFailed,
    [int]$MachinesInProgress,
    [int]$MachinesPending,
    [int]$MachinesSkipped
)   

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            }

    if([System.String]::IsNullOrWhiteSpace($Uid) -eq $false){
        $cmdArgs.Add('Uid',$Uid)
    }
    else{
        if($PSBoundParameters.ContainsKey('CatalogUid') -eq $true){
            $cmdArgs.Add('CatalogUid',$CatalogUid)
        }
        if($PSBoundParameters.ContainsKey('RebootScheduleName') -eq $true){
            $cmdArgs.Add('RebootScheduleName',$RebootScheduleName)
        }
        if($PSBoundParameters.ContainsKey('RebootDuration') -eq $true){
            $cmdArgs.Add('RebootDuration',$RebootDuration)
        }
        if($PSBoundParameters.ContainsKey('RestrictToTag') -eq $true){
            $cmdArgs.Add('RestrictToTag',$RestrictToTag)
        }
        if($MachinesCompleted -gt 0){
            $cmdArgs.Add('MachinesCompleted',$MachinesCompleted)
        }
        if($MachinesFailed -gt 0){
            $cmdArgs.Add('MachinesFailed',$MachinesFailed)
        }
        if($MachinesInProgress -gt 0){
            $cmdArgs.Add('MachinesInProgress',$MachinesInProgress)
        }
        if($MachinesPending -gt 0){
            $cmdArgs.Add('MachinesPending',$MachinesPending)
        }
        if($MachinesSkipped -gt 0){
            $cmdArgs.Add('MachinesSkipped',$MachinesSkipped)
        }
        
    }
    
    $ret = Get-BrokerRebootCycle @cmdArgs | Select-Object *
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
    CloseCitrixSession
}