#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        Gets the informations about SendAs permissions that are configured for users in a cloud-based organization
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Requires PS Module ExchangeOnlineManagement

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnlinev2/Recipients

    .Parameter Identity
        [sr-en] Specifies name, Alias or SamAccountName of the target recipient
        [sr-de] Name, Alias oder SamAccountNAme des Zielempfängers

    .Parameter Trustee
        [sr-en] Filters the results by the user or group to whom you're granting the permission
        [sr-de] Filtert die Ergebnisse nach dem Benutzer oder der Gruppe

    .Parameter ResultSize
        [sr-en] Specifies the maximum number of results to return
        [sr-de] Gibt die maximale Anzahl der zurückzugegebenen Ergebnisse an
#>

param(
    [string]$Identity,
    [string]$Trustee,
    [int]$ResultSize = 1000
)

Import-Module ExchangeOnlineManagement

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'ResultSize' = $ResultSize
    }

    if([System.String]::IsNullOrWhiteSpace($Identity) -eq $false){
        $cmdArgs.Add('Identity',$Identity)
    }
    if($PSBoundParameters.ContainsKey('Trustee') -eq $true){
        $cmdArgs.Add('Trustee',$Trustee)
    }
    $box = Get-EXORecipientPermission @cmdArgs
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $box
    } 
    else{
        Write-Output $box 
    }
}
catch{
    throw
}
finally{    
}