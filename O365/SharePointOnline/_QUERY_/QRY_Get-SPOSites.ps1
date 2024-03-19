#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Gets site collections
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.Online.SharePoint.PowerShell

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/_QUERY_

    .Parameter Limit
        [sr-en] Specifies the maximum number of site collections to return
        [sr-de] Gibt die maximale Anzahl der zurückzugebenden Site Collections an
#>

param(    
    [int]$Limit = 200
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [string[]]$Properties = @('Title','Url')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Detailed' = $Detailed
                            }      
    
    if($Limit -gt 0){
        $cmdArgs.Add('Limit',$Limit)
    }

    $result = Get-SPOSite @cmdArgs | Select-Object $Properties | Sort-Object Title

    foreach($itm in $result)
    {
        $null = $SRXEnv.ResultList.Add($itm.Url) # Value
        $null = $SRXEnv.ResultList2.Add($itm.Title) # Display
    } 
}
catch{
    throw
}
finally{
}