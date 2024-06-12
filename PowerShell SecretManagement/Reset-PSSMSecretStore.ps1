#Requires -Version 5.0
#Requires -Modules Microsoft.PowerShell.SecretStore

<#
    .SYNOPSIS
        Resets the SecretStore by deleting all secret data and configuring the store with default options
    
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
#>

param( 
)

Import-Module Microsoft.PowerShell.SecretStore

try{ 
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'PassThru' = $null
                        'Force' = $null
                        'Confirm' = $false
    }
    $sec = Reset-SecretStore @cmdArgs 

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