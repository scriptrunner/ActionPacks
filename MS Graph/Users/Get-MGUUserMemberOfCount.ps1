#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Get the number of the resource
    
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

    .PARAMETER Transitive
        [sr-en] Transitive
        [sr-de] 
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [switch]$Transitive
)

Import-Module Microsoft.Graph.Users

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'    
                        'UserId'= $UserId
                        'ConsistencyLevel' = 'eventual'
    }
    if($Transitive.IsPresent -eq $true){
        $mships = Get-MgUserTransitiveMemberOfCount @cmdArgs | Select-Object *
    }
    else{
        $mships = Get-MgUserMemberOfCount @cmdArgs | Select-Object *
    }    

    if($null -ne $SRXEnv) {
        $SRXEnv.ResultMessage = $mships
    }
    else{
        Write-Output $mships
    }    
}
catch{
    throw 
}
finally{
}