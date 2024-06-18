#Requires -Version 5.0
#Requires -Modules Microsoft.PowerShell.SecretManagement,Microsoft.PowerShell.SecretStore

<#
    .SYNOPSIS
        Adds a secret to a SecretManagement registered vault
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.PowerShell.SecretManagement,Microsoft.PowerShell.SecretStore

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/PowerShell Secretmanagement
        
    .Parameter SecretName
        [sr-en] Name of the secret
        [sr-de] Secret-Name
        
    .Parameter VaultName
        [sr-en] Name of the vault
        [sr-de] Vault-Name
        
    .Parameter SecretValue
        [sr-en] Value of the secret
        [sr-de] Wert des Secrets
        
    .Parameter OverwriteExistingSecret
        [sr-en] Updates the secret with the new value if it already exists
        [sr-de] Überschreiben eines existierenden Secrets mit dem selben Namen
        
    .Parameter StorePassword
        [sr-en] Password needed to access the store
        [sr-de] Kennwort für den Store Zugriff
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$SecretName,
    [Parameter(Mandatory = $true)]
    [SecureString]$SecretValue,
    [securestring]$StorePassword,
    [string]$VaultName,
    [string]$SecretInfo,
    [switch]$OverwriteExistingSecret
)

Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore

try{ 
    if($null -ne $StorePassword){
        Unlock-SecretStore -Password $StorePassword
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Name' = $SecretName
                    'Secret' = $SecretValue
                    'Confirm' = $false
    }
    if($PSBoundParameters.ContainsKey('VaultName') -eq $true){
        $cmdArgs.Add('Vault',$VaultName)
    }
   <# if($PSBoundParameters.ContainsKey('SecretInfo') -eq $true){
        $cmdArgs.Add('SecretInfo',$SecretInfo)
    }#>
    if($OverwriteExistingSecret.IsPresent -eq $false){
        $cmdArgs.Add('NoClobber',$true)
    }
    $null = Set-Secret @cmdArgs

    $sec = Get-Secret -Name $SecretName -ErrorAction Stop 
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