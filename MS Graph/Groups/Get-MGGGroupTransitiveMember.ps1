#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Groups 

<#
    .SYNOPSIS
        The direct and transitive members of a group
    
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
    [Validateset('AsApplication','AsDevice','AsGroup','AsOrgContact','AsServicePrincipal','AsUser')]
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
        'AsApplication'{
            $result = Get-MgGroupTransitiveMemberAsApplication @cmdArgs
        }
        'AsDevice'{
            $result = Get-MgGroupTransitiveMemberAsDevice @cmdArgs
        }
        'AsGroup'{
            $result = Get-MgGroupTransitiveMemberAsGroup @cmdArgs
        }
        'AsOrgContact'{
            $result = Get-MgGroupTransitiveMemberAsOrgContact @cmdArgs
        }
        'AsServicePrincipal'{
            $result = Get-MgGroupTransitiveMemberAsServicePrincipal @cmdArgs
        }
        'AsUser'{
            $result = Get-MgGroupTransitiveMemberAsUser @cmdArgs
        }
        default{
            $result = Get-MgGroupTransitiveMember @cmdArgs
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