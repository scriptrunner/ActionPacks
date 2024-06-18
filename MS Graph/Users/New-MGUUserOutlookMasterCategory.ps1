#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Create an outlookCategory object in the user's master list of categories
    
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

    .Parameter Color
        [sr-en] Color
        [sr-de] Farbe

    .Parameter DisplayName
        [sr-en] A unique name that identifies a category in the user's mailbox
        [sr-de] Eindeutiger Anzeigename
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,     
    [Parameter(Mandatory = $true)]
    [string]$Color, 
    [Parameter(Mandatory = $true)]
    [string]$DisplayName
)

Import-Module Microsoft.Graph.Users

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'    
                        'UserId'= $UserId
                        'Color' = $Color
                        'DisplayName' = $DisplayName
                        'Confirm' = $false
    }
    $result = New-MgUserOutlookMasterCategory @cmdArgs | Select-Object *
    
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