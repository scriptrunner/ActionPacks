#Requires -Version 5.0

<#
    .SYNOPSIS
        Sets the configuration to collect samples of license usage

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

    .Parameter Enable	
        [sr-en] To enable or disable the sample collection
        [sr-de] Aktivieren oder deaktivieren der Collection

    .Parameter PollingInterval	
        [sr-en] Specifies the Polling period (in minutes) for sample collection. Recommended polling period is 15 minutes
        [sr-de] Gibt den Abrufzeitraum (in Minuten) für die Collection an. Der empfohlene Abrufzeitraum beträgt 15 Minuten

    .Parameter RetentionPeriod	
        [sr-en] Specifies the retention period (in days) for license usage samples. 
        The recommended retention period is 180 days. You can configure any retention period. Minimum is 30 days.
        [sr-de] Gibt die Aufbewahrungsfrist (in Tagen) für Lizenznutzungsmuster an. 
        Die empfohlene Aufbewahrungsdauer beträgt 180 Tage. es kann eine beliebige Aufbewahrungsdauer konfiguriert werden. Das Minimum beträgt 30 Tage.

    .Parameter CitrixCredential
        [sr-en] Specifies the username/password to be authenticated with the License Server
        [sr-de] Benutzerkonto zum Authentifizieren am Lizenzserver
#>

param( 
    [string]$LicenseServer,
    [int]$LicenseServerPort = 27000,
    [ValidateSet('LS','VD','LAC','WSL')]
    [string]$AddressType = 'WSL',
    [bool]$Enabled,
    [ValidateRange(5,1440)]
    [int]$PollingInterval = 15,
    [ValidateRange(30,366)]
    [int]$RetentionPeriod = 180,
    [pscredential]$CitrixCredential
)

try{ 
    [string[]]$Properties = @('Enabled','PollingInterval','RetentionPeriod','EarliestSampleTime','LatestSampleTime')
    StartCitrixSession    

    $certi = $null
    GetLicenseCertificate -ServerName ([ref]$LicenseServer) -Certificate ([ref]$certi) -AddressType $AddressType -ServerPort $LicenseServerPort

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'CertHash' = $certi.CertHash
                            'AdminAddress' = $LicenseServer
                            'Enabled' = $Enabled
                            'RetentionPeriod' = $RetentionPeriod
                            'PollingInterval' = $PollingInterval
                            }
 
    if($PSBoundParameters.ContainsKey('CitrixCredential') -eq $true){
        $cmdArgs.Add('Credentials',$CitrixCredential)
    }   
    $null = Set-LicConfigUsageSamples @cmdArgs
    $ret = Get-LicConfigUsageSamples -AdminAddress $LicenseServer -CertHash $certi.CertHash -ErrorAction Stop | Select-Object $Properties
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