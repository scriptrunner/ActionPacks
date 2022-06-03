#Requires -Version 5.0

<#
    .SYNOPSIS
        Changes one or more of the licensing attributes of a Site
    
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

    .Parameter LicenseServerAddress
        [sr-en] Address of the License Server for this Site
        [sr-de] Adresse des Site Lizenz Servers

    .Parameter LicenseServerPort
        [sr-en] Port on which the License Server for this Site is listening
        [sr-de] Port des Lizenz Servers

    .Parameter LicensingModel
        [sr-en] Licensing model for this Site.
        [sr-de] Lizenz Modell der Site

    .Parameter ProductCode
        [sr-en] Product code for this Site.
        [sr-de] Product Code der Site

    .Parameter ProductEdition
        [sr-en] Product edition for this Site.
        [sr-de] Product Edition der Site

    .Parameter ProductCode
        [sr-en] Home zone preference to be associated with the user/group account
        [sr-de] Uid der Zone, der der Benutzer oder die Gruppe zugewiesen werden soll
#>

param( 
    [string]$LicenseServerAddress,
    [int]$LicenseServerPort = 27000,
    [string]$LicensingModel,
    [string]$ProductCode,
    [string]$ProductEdition,
    [string]$SiteServer    
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Force' = $null
                            'PassThru' = $null
                            'LicenseServerPort' = $LicenseServerPort
                            }    
    
    if($PSBoundParameters.ContainsKey('LicenseServerAddress') -eq $true){
        $cmdArgs.Add('LicenseServerAddress',$LicenseServerAddress)
    }
    if($PSBoundParameters.ContainsKey('ProductCode') -eq $true){
        $cmdArgs.Add('ProductCode',$ProductCode)
    }
    if($PSBoundParameters.ContainsKey('ProductEdition') -eq $true){
        $cmdArgs.Add('ProductEdition',$ProductEdition)
    }
    if($PSBoundParameters.ContainsKey('LicensingModel') -eq $true){
        $cmdArgs.Add('LicensingModel',$LicensingModel)
    }

    $ret = Set-XDLicensing @cmdArgs
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