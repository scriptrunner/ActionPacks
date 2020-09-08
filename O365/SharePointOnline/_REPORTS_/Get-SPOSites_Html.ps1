#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Generates a report with one or more sites
    
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

    .Parameter Limit
        [sr-en] Specifies the maximum number of site collections to return
        [sr-de] Gibt die maximale Anzahl der zurückzugebenden Site Collections an

    .Parameter Detailed
        [sr-en] Use this parameter to get additional property information on a site collection
        [sr-de] Zusätzliche Site Collection Properties 

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(    
    [switch]$Detailed,
    [int]$Limit = 200,
    [ValidateSet('*','Title','Status','Url','DisableFlows','AllowEditing','LastContentModifiedDate','CommentsOnSitePagesDisabled')]
    [string[]]$Properties = @('Title','Status','Url','DisableFlows','AllowEditing','LastContentModifiedDate','CommentsOnSitePagesDisabled')
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Detailed' = $Detailed
                            }      
    
    if($Limit -gt 0){
        $cmdArgs.Add('Limit',$Limit)
    }

    $result = Get-SPOSite @cmdArgs | Select-Object $Properties | Sort-Object Title

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