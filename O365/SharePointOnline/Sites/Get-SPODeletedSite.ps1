#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Returns all deleted site collections from the Recycle Bin
    
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
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Sites

    .Parameter Identity
        Specifies the URL of the deleted site collection to be returned

    .Parameter Limit
        Specifies the maximum number of site collections to return

    .Parameter IncludeOnlyPersonalSite
        Only include Personal Sites in the returned results

    .Parameter IncludePersonalSite
        Use this switch parameter to include Personal Sites with the returned results
#>

param(        
    [bool]$IncludePersonalSite,
    [bool]$IncludeOnlyPersonalSite,
    [string]$Identity,
    [int]$Limit = 200
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Limit' = $Limit
                            }      
    
    if([System.String]::IsNullOrWhiteSpace($Identity) -eq $false){
            $cmdArgs.Add('Identity',$Identity)
    }
    if($IncludeOnlyPersonalSite -eq $true){
        $cmdArgs.Add('IncludeOnlyPersonalSite',$true)  
    }
    else{
        $cmdArgs.Add('IncludePersonalSite',$IncludePersonalSite)     
    }

    $result = Get-SPODeletedSite @cmdArgs | Select-Object *

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
}