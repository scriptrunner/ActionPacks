#Requires -Version 5.0

<#
    .SYNOPSIS
        Grants a given right to the specified administrator
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Role
        [sr-en] Role name or role identifier
        [sr-de] Name oder Identifier der Rolle

    .Parameter Scope
        [sr-en] Scope name or scope identifier
        [sr-de] Name oder Identifier des Geltungsbereichs

    .Parameter Administrator
        [sr-en] Name or SID of the administrator
        [sr-de] Name oder SID des Administrators

    .Parameter All
        [sr-en] Specifies the 'All' scope
        [sr-de] Alle Geltungsbereiche
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = 'ByScope')]
    [Parameter(Mandatory = $true,ParameterSetName = 'All')]
    [string]$Administrator,
    [Parameter(Mandatory = $true,ParameterSetName = 'ByScope')]
    [Parameter(Mandatory = $true,ParameterSetName = 'All')]
    [string]$Role,
    [Parameter(Mandatory = $true,ParameterSetName = 'ByScope')]
    [string]$Scope,
    [Parameter(Mandatory = $true,ParameterSetName = 'All')]
    [switch]$All,    
    [Parameter(ParameterSetName = 'ByScope')]
    [Parameter(ParameterSetName = 'All')]
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Add Admin right $($Administrator)" -LoggingID ([ref]$LogID)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Role' = $Role
                            'Administrator' = $Administrator
                            }    
    
    if($PSCmdlet.ParameterSetName -eq 'All'){
        $cmdArgs.Add('All',$true)
    }
    else{
        $cmdArgs.Add('Scope',$Scope)
    }
    
    $null = Add-AdminRight @cmdArgs
    $success = $true
    $ret = Get-AdminAdministrator -Name $Administrator -AdminAddress $SiteServer -ErrorAction Stop | Select-Object *
    Write-Output $ret
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}