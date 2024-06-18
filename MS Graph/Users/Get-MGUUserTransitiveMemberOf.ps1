#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Returns groups, including nested groups, and directory roles that a user is a member of 
        
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

    .Parameter ResultType
        [sr-en] Type of the result
        [sr-de] Ergebnistyp
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [ValidateSet('AsAdministrativeUnit','AsDirectoryRole','AsGroup')]
    [string]$ResultType
)

Import-Module Microsoft.Graph.Users

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'    
                        'UserId'= $UserId
                        'All' = $null
    }
    switch ($ResultType){
        'AsAdministrativeUnit'{
            $result = Get-MgUserTransitiveMemberOfAsAdministrativeUnit @cmdArgs | Select-Object *
            break
        }
        'AsDirectoryRole'{
            $result = Get-MgUserTransitiveMemberOfAsDirectoryRole @cmdArgs | Select-Object *
            break
        }
        'AsGroup'{
            $result = Get-MgUserTransitiveMemberOfAsGroup @cmdArgs | Select-Object *
            break
        }
        default{
            $result = Get-MgUserTransitiveMemberOf @cmdArgs | Select-Object *
        }
    }
    
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