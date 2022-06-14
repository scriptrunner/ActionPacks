#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
    .SYNOPSIS
        Returns organizations
    
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
        Requires Modules Microsoft.Graph.Identity.DirectoryManagement

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Organization
#>

param( 
)

Import-Module Microsoft.Graph.Identity.DirectoryManagement

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                            'All' = $null
    }
    $result = Get-MgOrganization @cmdArgs | Select-Object @('DisplayName','Id')

    foreach($itm in $result){ # fill result lists
        if($null -ne $SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($itm.ID) # Value
            $null = $SRXEnv.ResultList2.Add($itm.DisplayName) # DisplayValue            
        }
        else{
            Write-Output $itm.DisplayName 
        }
    }
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}