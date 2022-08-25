#Requires -Version 5.0

<#
    .SYNOPSIS
        Add the specified catalog/desktop group to the given scope
    
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

    .Parameter Scope
        [sr-en] scope(s) to add the object to, GUID or its name
        [sr-de] Name des Geltungsbereichs

    .Parameter ApplicationGroup	
        [sr-en] Application group to be added, Uid or name 
        [sr-de] Uid oder Name der Anwendungsgruppe

    .Parameter Catalog 
        [sr-en] Catalog object to be added, Uid or name
        [sr-de] Uid oder Name des Maschinenkatalogs

    .Parameter DesktopGroup
        [sr-en] Desktop group object to be added, Uid or name
        [sr-de] Uid oder Name der Bereitstellungsgruppe
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Scope,
    [string]$ApplicationGroup,
    [string]$Catalog,
    [string]$DesktopGroup,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Add Scope $($Name)" -LoggingID ([ref]$LogID)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingID' = $LogID
                            'InputObject' = $Scope
                            }    
    if($PSBoundParameters.ContainsKey('ApplicationGroup') -eq $true){
        $cmdArgs.Add('ApplicationGroup',$ApplicationGroup)
    }
    if($PSBoundParameters.ContainsKey('Catalog') -eq $true){
        $cmdArgs.Add('Catalog',$Catalog)
    }
    if($PSBoundParameters.ContainsKey('DesktopGroup') -eq $true){
        $cmdArgs.Add('DesktopGroup',$DesktopGroup)
    }
    
    $ret = Add-BrokerScope @cmdArgs | Select-Object *
    $success = $true
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