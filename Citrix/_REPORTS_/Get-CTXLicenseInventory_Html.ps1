#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates a report with License Inventory Data from the License Server

    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_
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

    .Parameter CheckForSameSerialNumber
        [sr-en] Filters the Inventory result
        [sr-de] Filtert das Inventar-Ergebnis

    .Parameter CitrixCredential
        [sr-en] Specifies the username/password to be authenticated with the License Server
        [sr-de] Benutzerkonto zum Authentifizieren am Lizenzserver

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften

#>

param( 
    [string]$LicenseServer,
    [int]$LicenseServerPort = 27000,
    [ValidateSet('LS','VD','LAC','WSL')]
    [string]$AddressType = 'WSL',
    [switch]$CheckForSameSerialNumber,
    [string]$StringLanguage = 'EN',
    [pscredential]$CitrixCredential)

try{ 
    StartCitrixSession    
    [string[]]$Properties = @('LicenseProductName','LocalizedLicenseProductName','LicenseEdition','LicenseLocalizedEdition','LicenseExpirationDate','LicenseSubscriptionAdvantageDate','LicenseType','LocalizedLicenseType','LicensesInUse','LicensesAvailable','LicenseModel','LocalizedLicenseModel')

    $certi = $null
    GetLicenseCertificate -ServerName ([ref]$LicenseServer) -Certificate ([ref]$certi) -AddressType $AddressType -ServerPort $LicenseServerPort

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'CertHash' = $certi.CertHash
                            'AdminAddress' = $LicenseServer
                            'CheckForSameSerialNumber' = $CheckForSameSerialNumber
                            'Locale' = $StringLanguage
                            }
    if($PSBoundParameters.ContainsKey('CitrixCredential') -eq $true){
        $cmdArgs.Add('Credentials',$CitrixCredential)
    }                        
                        
    $lics = Get-LicInventory @cmdArgs | Select-Object $Properties
    ConvertTo-ResultHtml -result $lics     
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}