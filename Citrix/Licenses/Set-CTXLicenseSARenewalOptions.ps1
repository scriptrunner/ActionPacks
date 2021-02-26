#Requires -Version 5.0

<#
    .SYNOPSIS
        Sets the Customer Success Services renewal license check option on the License Server

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

    .Parameter CheckOption
        [sr-en] Specifies the Customer Success Services Renewal check option to be set on the License Server. 
        [sr-de] Option zur Überprüfung der Erneuerung der Customer Success Services Renewal

    .Parameter CitrixCredential
        [sr-en] Specifies the username/password to be authenticated with the License Server
        [sr-de] Benutzerkonto zum Authentifizieren am Lizenzserver
#>

param( 
    [Parameter(Mandatory = $true)]
    [ValidateSet('Notify','Install','Manual')]
    [string]$CheckOption,
    [string]$LicenseServer,
    [int]$LicenseServerPort = 27000,
    [ValidateSet('LS','VD','LAC','WSL')]
    [string]$AddressType = 'WSL',    
    [pscredential]$CitrixCredential
)

try{ 
    StartCitrixSession    

    $certi = $null
    GetLicenseCertificate -ServerName ([ref]$LicenseServer) -Certificate ([ref]$certi) -AddressType $AddressType -ServerPort $LicenseServerPort

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'CertHash' = $certi.CertHash
                            'AdminAddress' = $LicenseServer
                            'Option' = $CheckOption
                            }
     
    if($PSBoundParameters.ContainsKey('CitrixCredential') -eq $true){
        $cmdArgs.Add('Credentials',$CitrixCredential)
    }   

    $null = Set-LicSARenewalOptions @cmdArgs
    $ret = Get-LicSARenewalOptions -AdminAddress $LicenseServer -CertHash $certi.CertHash -ErrorAction Stop | Select-Object *
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