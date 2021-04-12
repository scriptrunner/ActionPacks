#Requires -Version 5.0

<#
    .SYNOPSIS
        Stop or log off a session
    
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
    StartLogging -ServerAddress $SiteServer -LogText "Stop session $($Script:ctxSession.UserName)" -LoggingID ([ref]$LogID)
    $null = Stop-BrokerSession -InputObject $Script:ctxSession.Uid -LoggingID $LogID -ErrorAction Stop
    $success = $true

    $ret = "Session $($Script:ctxSession.UserName) stopped"
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