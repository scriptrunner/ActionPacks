#Requires -Version 5.0

<#
    .SYNOPSIS
        Add permissions to the set of permissions of a role
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Permissions
        [sr-en] Permissions to add (by identifier), comma separated
        [sr-de] Hinzuzufügende Berechtigungen, Komma getrennt

    .Parameter QueryPermissions
        [sr-en] Permissions, find by the Query _\QUERY_\QRY_Get-CTXPermissions
        [sr-de] Berechtigungen, durch die Query _\QUERY_\QRY_Get-CTXPermissions abgefragt

    .Parameter Role
        [sr-en] Role name or identifier of the role to update
        [sr-de] Name oder Identifier der Rolle
#>

param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
    [string]$Permissions,
    [Parameter(Mandatory = $true, ParameterSetName = 'ByQuery',HelpMessage = "ASRDisplay(Multiline)")]
    [string[]]$QueryPermissions,
    [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
    [Parameter(Mandatory = $true, ParameterSetName = 'ByQuery')]
    [string]$Role,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'ByQuery')]
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Add permissions to role $($Role)" -LoggingID ([ref]$LogID)

    if($PSCmdlet.ParameterSetName -eq 'Default'){
        $QueryPermissions = $Permissions.Split(',')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Role' = $Role
                            'Permission' = $QueryPermissions
                            'LoggingId' = $LogID
                            }                             

    $null = Add-AdminPermission @cmdArgs
    $success = $true
    $ret = Get-AdminRole -AdminAddress $SiteServer -ErrorAction Stop | Where-Object {($_.Name -eq $Role) -or ($_.Id -eq $Role)} | Select-Object -Expand Permissions
    Write-Output $ret
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}