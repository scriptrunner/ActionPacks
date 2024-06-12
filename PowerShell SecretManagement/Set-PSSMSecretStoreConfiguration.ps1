#Requires -Version 5.0
#Requires -Modules Microsoft.PowerShell.SecretStore

<#
    .SYNOPSIS
        Configures the SecretStore
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.PowerShell.SecretStore

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/PowerShell Secretmanagement

    .PARAMETER Authentication
        [sr-en] Authenticate access to the SecretStore
        [sr-de] Authentifizierung

    .PARAMETER StorePassword    
        [sr-en] Password to access the SecretStore
        [sr-de] Store Kennwort

    .PARAMETER PasswordTimeout
        [sr-en] Seconds the SecretStore remains unlocked after authenticating with a password
        [sr-de] Sekunden die den SecretStore nach der Authentifizierung mit einem Passwort entsperrt

    .PARAMETER Default
        [sr-en] Set to default configuration
        [sr-de] Standardeinstellungen
#>

param( 
    [ValidateSet('None','Password')]
    [string]$Authentication,
    [securestring]$StorePassword,
    [int]$PasswordTimeout = 900,
    [switch]$Default
)

Import-Module Microsoft.PowerShell.SecretStore

try{ 
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'PassThru' = $null
                    'Confirm' = $false
    }
    if($Default.IsPresent -eq $true){
        $cmdArgs.Add('Default',$true)
    }
    else {
        if($PSBoundParameters.ContainsKey('Authentication') -eq $true){
            $cmdArgs.Add('Authentication',$Authentication)
        }
        if($PSBoundParameters.ContainsKey('StorePassword') -eq $true){
            $cmdArgs.Add('Password',$StorePassword)
        }
        if($PSBoundParameters.ContainsKey('PasswordTimeout') -eq $true){
            $cmdArgs.Add('Default',$PasswordTimeout)
        }
    }
    $sec = Set-SecretStoreConfiguration @cmdArgs 

    if($null -ne $SRXEnv) {
        $SRXEnv.ResultMessage = $sec
    }
    else{
        Write-Output $sec
    }
}
catch{
    throw
}
finally{
}