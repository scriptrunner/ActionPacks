#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Updates the attributes of a secret in a key vault
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults

    .Parameter SecretName
        [sr-en] Name of the secret
        [sr-de] Namen des Secrets

    .Parameter NotBefore
        [sr-en] Time before which secret can't be used  
        [sr-de] Zeitpunkt ab wann das Secret verwendet werden kann

    .Parameter Expires
        [sr-en] Expiration time of a secret
        [sr-de] Ablaufzeit des Secrets

    .Parameter Enable
        [sr-en] Enable a secret
        [sr-de] Secret aktivieren
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$SecretName,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$NotBefore,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$Expires,
    [bool]$Enable
)

Import-Module Az.KeyVault

try{
    [string[]]$Properties = @('VaultName','Name','NotBefore','Expires','Enabled')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'Name' = $SecretName
                'Confirm' = $false
                'PassThru' = $null
    }
    
    if($PSBoundParameters.ContainsKey('NotBefore') -eq $true){
        $cmdArgs.Add('NotBefore',$NotBefore)
    }
    if($PSBoundParameters.ContainsKey('Expires') -eq $true){
        $cmdArgs.Add('Expires',$Expires)
    }
    if($PSBoundParameters.ContainsKey('Enable') -eq $true){
        $cmdArgs.Add('Enable',$Enable)
    }
    $ret = Update-AzKeyVaultSecret @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}