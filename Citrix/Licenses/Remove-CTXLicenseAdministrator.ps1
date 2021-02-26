#Requires -Version 5.0

<#
    .SYNOPSIS
        Removes an Active Directory account or group from the list of administrators on the License Server
    
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
        
    .Parameter Account
        [sr-en] Specifies the Active Directory account or group to be removed from the list of administrators from the License Server
        The account must be specified in domain-qualified format, that is, <Domain>\<Account> or <Account>@<Domain>.
        [sr-de] Gibt das Active Directory-Konto oder die Active Directory-Gruppe an, das gelöscht wird. 
        Das Konto muss im Domänen-qualifizierten Format angegeben werden, d.h. <Domäne>\<Konto> oder <Konto>@<Domäne>.   
        
    .Parameter CitrixCredential
        [sr-en] Specifies the username/password to be authenticated with the License Server
        [sr-de] Benutzerkonto zum Authentifizieren am Lizenzserver 
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Account,
    [string]$LicenseServer,
    [int]$LicenseServerPort = 27000,
    [ValidateSet('LS','VD','LAC','WSL')]
    [string]$AddressType = 'WSL',
    [pscredential]$CitrixCredential
)                                                            

try{ 
    [string[]]$Properties = @('Account','Group','Permissions')
    StartCitrixSession
    
    $certi = $null
    GetLicenseCertificate -ServerName ([ref]$LicenseServer) -AddressType $AddressType -ServerPort $LicenseServerPort -Certificate ([ref]$certi)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $LicenseServer
                            'Account' = $Account
                            'CertHash' = $certi.CertHash
                            }

    if($PSBoundParameters.ContainsKey('CitrixCredential') -eq $true){
        $cmdArgs.Add('Credentials',$CitrixCredential)
    } 
    $null = Remove-LicAdministrator @cmdArgs

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'AdminAddress' = $LicenseServer
                'CertHash' = $certi.CertHash
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