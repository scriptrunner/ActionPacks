#Requires -Version 5.0

<#
    .SYNOPSIS
        Disconnect a session
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter SessionKey
        [sr-en] Session having the specified unique key
        [sr-de] Schlüssel Sitzung

    .Parameter UId
        [sr-en] Session by Uid
        [sr-de] UId der Sitzung

    .Parameter UserName
        [sr-en] Session of this user (in the form DOMAIN\user)
        [sr-de] Sitzung dieses Benutzers (Domäne\Benutzername)
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = 'byId')]
    [Int64]$UId,
    [Parameter(Mandatory = $true,ParameterSetName = 'byKey')]
    [string]$SessionKey,
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [string]$UserName,
    [Parameter(ParameterSetName = 'byId')]
    [Parameter(ParameterSetName = 'byKey')]
    [Parameter(ParameterSetName = 'ByName')]
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    $Script:ctxSession
    [string[]]$Properties = @('UserName','SessionState','Uid','SessionKey','ApplicationsInUse','StartTime','CatalogName','DesktopGroupName','ZoneName','EstablishmentTime')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            }    
    
    if($PSCmdlet.ParameterSetName -eq 'byId'){
        $Script:ctxSession = Get-BrokerSession @cmdArgs -Uid $UId
    }
    elseif($PSCmdlet.ParameterSetName -eq 'byKey'){
        $Script:ctxSession = Get-BrokerSession @cmdArgs -SessionKey $SessionKey
    }
    else{
        $Script:ctxSession = Get-BrokerSession @cmdArgs -UserName  $UserName
    }
    StartLogging -ServerAddress $SiteServer -LogText "Disconnect session $($Script:ctxSession.UserName)" -LoggingID ([ref]$LogID)
    $null = Disconnect-BrokerSession -InputObject $Script:ctxSession.Uid -LoggingID $LogID -ErrorAction Stop
    Start-Sleep -Seconds 5
    $success = $true

    $ret = Get-BrokerSession @cmdArgs -Uid $Script:ctxSession.Uid | Select-Object $Properties
    Write-Output $ret
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}