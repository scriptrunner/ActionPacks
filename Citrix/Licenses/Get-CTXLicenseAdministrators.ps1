#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets a list of administrator accounts configured to access the License Server
    
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
        
    .Parameter AccountSid	
        [sr-en] Specifies the security identifier of the account to be located
        [sr-de] Sicherheitskennung des Kontos    
        
    .Parameter ReadOnly	
        [sr-en] Specifies that only administrator accounts with read-only permissions should be returned
        [sr-de] Nur Administratorkonten mit ReadOnly-Berechtigungen werden zurückgegeben 

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
    [string]$AccountSid,
    [switch]$ReadOnly,
    [pscredential]$CitrixCredential,
    [ValidateSet('*','Account','AccountSid','Group','Permissions')]
    [string[]]$Properties = @('Account','Group','Permissions')
)                                                            

try{ 
    StartCitrixSession
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    $certi = $null
    GetLicenseCertificate -ServerName ([ref]$LicenseServer) -AddressType $AddressType -ServerPort $LicenseServerPort -Certificate ([ref]$certi)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $LicenseServer
                            'CertHash' = $certi.CertHash
                            'ReadOnly' = $ReadOnly
                            }

    if($PSBoundParameters.ContainsKey('AccountSid') -eq $true){
        $cmdArgs.Add('AccountSid',$AccountSid)
    }     
    if($PSBoundParameters.ContainsKey('CitrixCredential') -eq $true){
        $cmdArgs.Add('Credentials',$CitrixCredential)
    }                        
    $ret = Get-LicAdministrator @cmdArgs | Select-Object $Properties

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