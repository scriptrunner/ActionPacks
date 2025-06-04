#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets permissions configured for the site
    
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
        [sr-en] Permissions with the specified name (localized)        
        [sr-de] Berechtigungen mit diesem lokalisierten Namen
        Dieser Parameter unterstützt Wildcards am Anfang und/oder am Ende des Namens

    .Parameter Id
        [sr-en] Permission with the specified id
        [sr-de] Identifier der Berechtigung

    .Parameter Description
        [sr-en] Permissions with the specified description
        [sr-de] Berechtigungen mit dieser Beschreibung
        
    .Parameter GroupId	
        [sr-en] Permissions that are a member of the specified permission group (by group id)
        [sr-de] Berechtigungen die Mitglieder dieser Gruppe sind (Id)

    .Parameter GroupName	
        [sr-en] Permissions that are a member of the specified permission group (by group name)
        [sr-de] Berechtigungen die Mitglieder dieser Gruppe sind (Name)

    .Parameter Operation	
        [sr-en] Permissions that contain a specific operation
        [sr-de] Operation der Berechtigungen

    .Parameter ReadOnly	
        [sr-en] Permissions with ReadOnly J/N 
        [sr-de] ReadOnly Berechtigungen J/N

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(
    [string]$Name,
    [string]$Id,
    [string]$SiteServer,   
    [string]$GroupName,
    [string]$GroupId,    
    [string]$Description,
    [string]$Operation,
    [bool]$ReadOnly,   
    [int]$MaxRecordCount = 250, 
    [ValidateSet('*','Name','Id','IsHidden','ReadOnly','Description','GroupId','GroupName','Operations','MetadataMap')]
    [string[]]$Properties = @('Name','Id','Description','GroupName','IsHidden','ReadOnly')
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'MaxRecordCount' = $MaxRecordCount
                            }    
    
    if($PSBoundParameters.ContainsKey('Id') -eq $true){
        $cmdArgs.Add('Id',$Id)
    }
    if($PSBoundParameters.ContainsKey('Name') -eq $true){
        $cmdArgs.Add('Name',$Name)
    }
    if($PSBoundParameters.ContainsKey('GroupId') -eq $true){
        $cmdArgs.Add('GroupId',$GroupId)
    }
    if($PSBoundParameters.ContainsKey('GroupName') -eq $true){
        $cmdArgs.Add('GroupName',$GroupName)
    }    
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('Operation') -eq $true){
        $cmdArgs.Add('Operation',$Operation)
    }
    if($PSBoundParameters.ContainsKey('ReadOnly') -eq $true){
        $cmdArgs.Add('ReadOnly',$ReadOnly)
    }

    $ret = Get-AdminPermission @cmdArgs | Select-Object $Properties | Sort-Object Name
    Write-Output $ret
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}