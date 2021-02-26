#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets the current XenDesktop broker site
    
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

    .Parameter ReuseMachinesWithoutShutdownInOutageAllowed  
        [sr-en] Specifies whether or not power cycle behavior during outage can be overriden on a delivery group level
        [sr-de] Einschaltverhalten während eines Ausfalls auf Bereitstellungsgruppenebene übersteuern J/N

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$SiteServer,
    [bool]$ReuseMachinesWithoutShutdownInOutageAllowed ,
    [ValidateSet('*','Name','ConfigLastChangeTime','ConnectionLeasingEnabled','DeleteResourceLeasesOnLogOff','LicenseEdition','LicenseModel','LicenseServerName','LicensedSessionsActive','LicenseServerPort','LocalHostCacheEnabled','PeakConcurrentLicenseUsers','PeakConcurrentLicensedDevices','ReuseMachinesWithoutShutdownInOutageAllowed','TotalUniqueLicenseUsers')]
    [string[]]$Properties = @('Name','ConfigLastChangeTime','ConnectionLeasingEnabled','LicenseEdition','LicenseModel','LicenseServerName','LicensedSessionsActive','ReuseMachinesWithoutShutdownInOutageAllowed')
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'ReuseMachinesWithoutShutdownInOutageAllowed' = $ReuseMachinesWithoutShutdownInOutageAllowed
                            }    
    
    $ret = Get-BrokerSite @cmdArgs | Select-Object $Properties
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