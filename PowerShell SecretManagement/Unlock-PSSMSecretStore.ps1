#Requires -Version 5.0
#Requires -Modules Microsoft.PowerShell.SecretStore

<#
    .SYNOPSIS
        Unlocks SecretStore with the provided password
    
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
        
    .PARAMETER PasswordTimeout
        [sr-en] Seconds the SecretStore remains unlocked after authenticating with a password
        [sr-de] Sekunden die den SecretStore nach der Authentifizierung mit einem Passwort entsperrt
        
    .Parameter StorePassword
        [sr-en] Password needed to access the stroe
        [sr-de] Kennwort für den Store Zugriff
#>

param( 
    [Parameter(Mandatory = $true)]
    [securestring]$StorePassword,
    [int]$PasswordTimeout = 900
)

Import-Module Microsoft.PowerShell.SecretStore

try{ 
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'PasswordTimeout' = $PasswordTimeout
                    'Password' = $StorePassword
    }
    $result = Unlock-SecretStore @cmdArgs

    if($null -ne $SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{
}