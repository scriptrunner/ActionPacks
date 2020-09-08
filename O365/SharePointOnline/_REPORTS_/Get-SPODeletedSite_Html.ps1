#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Generates a report with all deleted site collections from the Recycle Bin
    
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
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/_REPORTS_

    .Parameter Identity
        [sr-en] Specifies the URL of the deleted site collection to be returned
        [sr-de] Gibt die URL der wiederherzustellenden gelöschten Webitesammlung an

    .Parameter Limit
        [sr-en] Specifies the maximum number of site collections to return
        [sr-de] Gibt die maximale Anzahl der zurückzugebenden Site Collections an

    .Parameter IncludeOnlyPersonalSite
        [sr-en] Only include Personal Sites in the returned results
        [sr-de] Nur persönliche Websites

    .Parameter IncludePersonalSite
        [sr-en] Use this switch parameter to include Personal Sites with the returned results
        [sr-de] Persönliche Websites ins Ergebnis einbeziehen
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
        ConvertTo-ResultHtml -Result $result    
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