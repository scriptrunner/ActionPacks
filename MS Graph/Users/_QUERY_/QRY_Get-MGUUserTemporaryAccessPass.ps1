#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Identity.SignIns

<#
    .SYNOPSIS
        Retrieve the user's single temporaryAccessPassAuthenticationMethod objects
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Identity.SignIns

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId
)

Import-Module Microsoft.Graph.Identity.SignIns

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'UserId' = $UserId
    }
    $result = Get-MgUserAuthenticationTemporaryAccessPassMethod @cmdArgs -All 

    foreach($itm in $result){ # fill result lists
        if($null -ne $SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($itm.Id) # Value
            $null = $SRXEnv.ResultList2.Add("Started: $($itm.StartDateTime)") # DisplayValue            
        }
        else{
            Write-Output $itm.StartDateTime 
        }
    }  
}
catch{
    throw 
}