#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets the self-signed X509 certificate from the specified License Server
    
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
    
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$LicenseServer,
    [int]$LicenseServerPort = 27000,
    [ValidateSet('LS','VD','LAC','WSL')]
    [string]$AddressType = 'WSL',
    [ValidateSet('*','Subject','Thumbprint','SerialNumber','NotBefore','NotAfter','Archived','DnsNameList','SendAsTrustedIssuer','HasPrivateKey','PrivateKey','PublicKey','Version','Handle')]
    [string[]]$Properties = @('Subject','Thumbprint','SerialNumber','NotBefore','NotAfter','Archived','DnsNameList')
)

try{ 
    StartCitrixSession
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    $certi = $null
    GetLicenseCertificate -ServerName ([ref]$LicenseServer) -AddressType $AddressType -ServerPort $LicenseServerPort -Certificate ([ref]$certi)
    $ret = $certi | Select-Object -ExpandProperty Certificate | Select-Object $Properties

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