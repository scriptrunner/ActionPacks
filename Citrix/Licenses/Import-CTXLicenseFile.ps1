#Requires -Version 5.0

<#
    .SYNOPSIS
        Import License File to the License Server

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

    .Parameter LicenseFile
        [sr-en] Full Path to the Location of the License File
        [sr-de] Pfad und Name der Lizenzdatei

    .Parameter Overwrite
        [sr-en] Overwrite an existing file with the same filename
        [sr-de] Vorhandene Datei mit dem gleichen Dateinamen überschreiben
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$LicenseFile,
    [switch]$Overwrite,
    [string]$LicenseServer,
    [int]$LicenseServerPort = 27000,
    [ValidateSet('LS','VD','LAC','WSL')]
    [string]$AddressType = 'WSL'
)

try{ 
    StartCitrixSession 

    $certi = $null
    GetLicenseCertificate -ServerName ([ref]$LicenseServer) -Certificate ([ref]$certi) -AddressType $AddressType -ServerPort $LicenseServerPort

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'CertHash' = $certi.CertHash
                            'AdminAddress' = $LicenseServer
                            'FileName' = $LicenseFile
                            'Overwrite' = $Overwrite
                            }

    $ret = Import-LicLicenseFile @cmdArgs | Select-Object *
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