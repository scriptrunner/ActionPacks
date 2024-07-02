#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Groups 

<#
    .SYNOPSIS
        The groups that a group is a member of, either directly or through nested membership
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Library script MS Graph\_LIB_\MGLibrary
        Requires Modules Microsoft.Graph.Groups 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Groups
      
    .Parameter GroupId
        [sr-en] Group identifier
        [sr-de] Gruppen ID

    .Parameter ResultType
        [sr-en] Type of the result
        [sr-de] Ergebnistyp
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Validateset('AsAdministrativeUnit','AsGroup')]
    [string]$ResultType
)

Import-Module Microsoft.Graph.Groups

try{
    $result = $null
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'GroupId' = $GroupId
                    'All' = $null
    }
    
    switch($ResultType){
        'AsAdministrativeUnit'{
            $result = Get-MgGroupTransitiveMemberOfAsAdministrativeUnit @cmdArgs
        }
        'AsGroup'{
            $result = Get-MgGroupTransitiveMemberOfAsGroup @cmdArgs
        }
        default{
            $result = Get-MgGroupTransitiveMemberOf @cmdArgs
        }
    }    
    
    if (Get-Command 'ConvertTo-ResultHtml' -ErrorAction Ignore) {
        ConvertTo-ResultHtml -Result $result
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