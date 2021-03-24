#Requires -Version 5.0

<#
    .SYNOPSIS
        Associate a tag with another object in the site
    
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

    .Parameter Name
        [sr-en] Name of the tag
        [sr-de] Name des Tags

    .Parameter Application
        [sr-en] Associates the tag with the specified application
        [sr-de] Verbindet das Tag mit der angegebenen Anwendung

    .Parameter ApplicationGroup	
        [sr-en] Associates the tag with the specified application group
        [sr-de] Verbindet das Tag mit der angegebenen Anwendungsgruppe

    .Parameter Desktop
        [sr-en] Associates the tag with the specified desktop
        [sr-de] das Tag mit dem angegebenen Desktop
        
    .Parameter DesktopGroup	
        [sr-en] Associates the tag with the specified desktop group
        [sr-de] Verbindet das Tag mit der angegebenen Desktop-Gruppe

    .Parameter Machine	
        [sr-en] Associates the tag with the specified machine
        [sr-de] Verbindet das Tag mit der angegebenen Maschine
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string]$Application,
    [string]$ApplicationGroup,
    [string]$Desktop,
    [string]$DesktopGroup,
    [string]$Machine,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Associates the tag $($Name) with object" -LoggingID ([ref]$LogID)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingID' = $LogID
                            'Name' = $Name
                            }    
    
    if($PSBoundParameters.ContainsKey('Application') -eq $true){
        $cmdArgs.Add('Application',$Application)
    }
    if($PSBoundParameters.ContainsKey('ApplicationGroup') -eq $true){
        $cmdArgs.Add('ApplicationGroup',$ApplicationGroup)
    }
    if($PSBoundParameters.ContainsKey('Desktop') -eq $true){
        $cmdArgs.Add('Desktop',$Desktop)
    }    
    if($PSBoundParameters.ContainsKey('DesktopGroup') -eq $true){
        $cmdArgs.Add('DesktopGroup',$DesktopGroup)
    }    
    if($PSBoundParameters.ContainsKey('Machine') -eq $true){
        $cmdArgs.Add('Machine',$Machine)
    }
    
    $ret = Add-BrokerTag @cmdArgs | Select-Object *
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