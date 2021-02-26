#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets the friendly name of the products and license types saved on License Server

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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Licenses
        
    .Parameter LicenseServer
        [sr-en] Address of the license server
        [sr-de] Name des Lizenzservers

    .Parameter LicenseServerPort
        [sr-en] License Server port number
        [sr-de] Port des Lizenzservers

    .Parameter AddressType
        [sr-en] Address type of the License Service
        [sr-de] Adresstyp des Lizenzdienstes

    .Parameter StringLanguage
        [sr-en] Language code of localized human readable strings
        [sr-de] Sprachcode
#>

param( 
    [string]$LicenseServer,
    [int]$LicenseServerPort = 27000,
    [ValidateSet('LS','VD','LAC','WSL')]
    [string]$AddressType = 'WSL',
    [string]$StringLanguage = 'EN'
)

try{ 
    StartCitrixSession 

    $certi = $null
    GetLicenseCertificate -ServerName ([ref]$LicenseServer) -Certificate ([ref]$certi) -AddressType $AddressType -ServerPort $LicenseServerPort

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'CertHash' = $certi.CertHash
                            'AdminAddress' = $LicenseServer
                            'Locale' = $StringLanguage
                            }
    $tmp = Get-LicLocalizedNames @cmdArgs | Select-Object ('Features','LicenseTypes')

    [string[]]$ret = @('Features')
    $ret += $tmp.Features | Out-String
    $ret += 'License types'
    $ret += $tmp.LicenseTypes | Out-String

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