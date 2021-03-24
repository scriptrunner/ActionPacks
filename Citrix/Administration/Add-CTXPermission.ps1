#Requires -Version 5.0

<#
    .SYNOPSIS
        Add permissions to the set of permissions of a role
    
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

    .Parameter Permissions
        [sr-en] Permissions to add (by identifier), comma separated
        [sr-de] Hinzuzufügende Berechtigungen, Komma getrennt

    .Parameter QueryPermissions
        [sr-en] Permissions, find by the Query _\QUERY_\QUY_Get-CTXPermissions
        [sr-de] Berechtigungen, durch die Query _\QUERY_\QUY_Get-CTXPermissions abgefragt

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