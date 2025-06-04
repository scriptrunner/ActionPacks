#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets users configured for this site
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Name
        [sr-en] User with the specified Name
        [sr-de] Benutzername

    .Parameter FullName
        [sr-en] User with the specified FullName
        [sr-de] Benutzername (FullName)

    .Parameter SID
        [sr-en] User with the specified SID
        [sr-de] Benutzer SID

    .Parameter HomeZoneName
        [sr-en] User/group accounts having a home zone preference matching the specified name
        [sr-de] Benutzer/Gruppen mit diesem Home Zone Namen

    .Parameter UPN
        [sr-en] User with the specified UPN
        [sr-de] Benutzername (UPN)

    .Parameter ApplicationGroupUid	
        [sr-en] Users associated with the application group with the specified Uid
        [sr-de] Verbundene Benutzer mit der angegebenen Anwendungsgruppen Uid

    .Parameter ApplicationUid	
        [sr-en] Users associated with the application with the specified Uid
        [sr-de] Verbundene Benutzer mit der angegebenen Anwendungs Uid

    .Parameter MachineUid
        [sr-en] Users associated with the broker machine with the specified Uid
        [sr-de] Verbundene Benutzer mit der angegebenen Rechner Uid

    .Parameter PrivateDesktopUid
        [sr-en] Users associated with the private desktop with the specified Uid
        [sr-de] Verbundene Benutzer mit der angegebenen privaten Desktop Uid

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = 'byId')]
    [string]$SID,
    [Parameter(ParameterSetName = 'Default')]
    [string]$Name,
    [Parameter(ParameterSetName = 'Default')]
    [string]$FullName,
    [Parameter(ParameterSetName = 'Default')]
    [string]$UPN,
    [Parameter(ParameterSetName = 'Default')]
    [string]$HomeZoneName,
    [Parameter(ParameterSetName = 'Default')]
    [int]$ApplicationGroupUid,
    [Parameter(ParameterSetName = 'Default')]
    [int]$ApplicationUid,
    [Parameter(ParameterSetName = 'Default')]
    [int]$MachineUid,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$PrivateDesktopUid,
    [Parameter(ParameterSetName = 'Default')]
    [int]$MaxRecordCount = 250,
    [Parameter(ParameterSetName = 'byId')]
    [Parameter(ParameterSetName = 'Default')]
    [string]$SiteServer,
    [Parameter(ParameterSetName = 'byId')]
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('*','Name','FullName','HomeZoneName','HomeZoneUid','SID','UPN')]
    [string[]]$Properties = @('Name','FullName','HomeZoneName','UPN','SID')
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            }    
    
    if($PSCmdlet.ParameterSetName -eq 'byId'){
        $cmdArgs.Add('SID',$SID)
    }
    else{
        $cmdArgs.Add('MaxRecordCount',$MaxRecordCount)
    }
    if($PSBoundParameters.ContainsKey('Name') -eq $true){
        $cmdArgs.Add('Name',$Name)
    }
    if($PSBoundParameters.ContainsKey('FullName') -eq $true){
        $cmdArgs.Add('FullName',$FullName)
    }
    if($PSBoundParameters.ContainsKey('UPN') -eq $true){
        $cmdArgs.Add('UPN',$UPN)
    }
    if($PSBoundParameters.ContainsKey('HomeZoneName') -eq $true){
        $cmdArgs.Add('HomeZoneName',$HomeZoneName)
    }
    if($PSBoundParameters.ContainsKey('ApplicationGroupUid') -eq $true){
        $cmdArgs.Add('ApplicationGroupUid',$ApplicationGroupUid)
    }
    if($PSBoundParameters.ContainsKey('ApplicationUid') -eq $true){
        $cmdArgs.Add('ApplicationUid',$ApplicationUid)
    }
    if($PSBoundParameters.ContainsKey('MachineUid') -eq $true){
        $cmdArgs.Add('MachineUid',$MachineUid)
    }
    if($PSBoundParameters.ContainsKey('PrivateDesktopUid') -eq $true){
        $cmdArgs.Add('PrivateDesktopUid',$PrivateDesktopUid)
    }
    
    $ret = Get-BrokerUser @cmdArgs | Select-Object $Properties
    Write-Output $ret
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}