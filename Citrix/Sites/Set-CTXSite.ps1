#Requires -Version 5.0

<#
    .SYNOPSIS
        Changes the overall settings of the current XenDesktop broker site
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Sites
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter ColorDepth
        [sr-en] Changes the default color depth for new desktop groups
        [sr-de] Ändert die Standardfarbtiefe für neue Desktop-Gruppen

    .Parameter LocalHostCacheEnabled	
        [sr-en] If the Local Host Cache feature is available, this property enables or disables it at run-time
        [sr-de] Aktiviert oder deaktiviert die Funktion "Local Host Cache", falls verfügbar

    .Parameter ReuseMachinesWithoutShutdownInOutageAllowed  
        [sr-en] Allows the ReuseMachinesWithoutShutdownInOutage setting on individual DesktopGroups to be enabled
        [sr-de] Ermöglicht die Aktivierung der Einstellung auf einzelnen Bereitstellungsgruppenebene

    .Parameter SecureIcaRequired  
        [sr-en] Changes the default SecureICA usage requirements for new desktop groups if no SecureICA setting is specified explicitly when a group is created
        [sr-de] Ändert die Standardanforderungen für die SecureICA-Nutzung für neue Desktop-Gruppen, wenn beim Anlegen einer Gruppe keine SecureICA-Einstellung explizit angegeben wird
#>

param( 
    [string]$SiteServer,
    [ValidateSet('FourBit','EightBit','SixteenBit','TwentyFourBit')]
    [string]$ColorDepth,
    [bool]$LocalHostCacheEnabled,
    [bool]$ReuseMachinesWithoutShutdownInOutageAllowed,
    [bool]$TrustRequestsSentToTheXmlServicePort,
    [bool]$SecureIcaRequired
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','ConfigLastChangeTime','ConnectionLeasingEnabled','LicenseEdition','LicenseModel','LicenseServerName','LicensedSessionsActive','ReuseMachinesWithoutShutdownInOutageAllowed')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    $ret = Get-BrokerSite -AdminAddress $SiteServer -ErrorAction Stop
    StartLogging -ServerAddress $SiteServer -LogText "Change Site $($ret.Name)" -LoggingID ([ref]$LogID)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingId' = $LogID
                            'PassThru' = $null
                            }    
    
    if($PSBoundParameters.ContainsKey('ColorDepth') -eq $true){
        $cmdArgs.Add('ColorDepth',$ColorDepth)
    }
    if($PSBoundParameters.ContainsKey('LocalHostCacheEnabled') -eq $true){
        $cmdArgs.Add('LocalHostCacheEnabled',$LocalHostCacheEnabled)
    }
    if($PSBoundParameters.ContainsKey('TrustRequestsSentToTheXmlServicePort') -eq $true){
        $cmdArgs.Add('TrustRequestsSentToTheXmlServicePort',$TrustRequestsSentToTheXmlServicePort)
    }
    if($PSBoundParameters.ContainsKey('ReuseMachinesWithoutShutdownInOutageAllowed') -eq $true){
        $cmdArgs.Add('ReuseMachinesWithoutShutdownInOutageAllowed',$ReuseMachinesWithoutShutdownInOutageAllowed)
    }
    if($PSBoundParameters.ContainsKey('SecureIcaRequired') -eq $true){
        $cmdArgs.Add('SecureIcaRequired',$SecureIcaRequired)
    }

    $null = Set-BrokerSite @cmdArgs               
    $success = $true
    $ret = Get-BrokerSite -AdminAddress $SiteServer -ErrorAction Stop | Select-Object $Properties
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