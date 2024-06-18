#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Sets user's manager
        
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Users

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Users

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .PARAMETER ManagerId
        [sr-en] Id of the manager
        [sr-de] Manager Id
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [Parameter(Mandatory = $true)]
    [string]$ManagerId
)

Import-Module Microsoft.Graph.Users

try{
    $null = Get-MgUser -UserId $ManagerId | Select-Object ID
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'UserId' = $UserId
                'OdataId' = "https://graph.microsoft.com/v1.0/directoryObjects/$($ManagerId)"
                'Confirm' = $false
                'PassThru' = $null
    }
    $result = Set-MgUserManagerByRef @cmdArgs

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