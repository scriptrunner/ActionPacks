#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Returns a collection of resources linked to the task
    
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
        Requires Modules Microsoft.Graph.Users

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Users

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId
)

Import-Module Microsoft.Graph.Users

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'    
                        'UserId'= $UserId
                        'All' = $null
    }
    $res = Get-MgUserTransitiveMember @cmdArgs | Select-Object *

    [PSCustomObject]$result = @()
    foreach($obj in $res){
        [PSCustomObject]$item = [PSCustomObject]@{
            'DeletedDateTime' = $obj.DeletedDateTime
            'Id' = $obj.Id
            'Type' = $obj.AdditionalProperties.Item('@odata.type').Replace('#microsoft.graph.','')
            'CreatedDateTime' = $obj.AdditionalProperties.createdDateTime
            'DisplayName' = $obj.AdditionalProperties.displayName
            'Description' = $obj.AdditionalProperties.description
            'GroupTypes' = $obj.AdditionalProperties.groupTypes
            'Mail' = $obj.AdditionalProperties.mail
        }
        $result += $item
    }
          
    $result = $result | Sort-Object DisplayName

    if (Get-Command 'ConvertTo-ResultHtml' -ErrorAction Ignore) {
        ConvertTo-ResultHtml -Result $result
    }
    if($SRXEnv) {
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
    DisconnectMSGraph
}