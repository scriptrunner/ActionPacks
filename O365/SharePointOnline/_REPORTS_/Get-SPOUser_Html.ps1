#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Generates a report with the SharePoint Online user or security group accounts that match a given search criteria
    
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

    .Parameter Site
        [sr-en] Specifies the URL of the site collection to get the user from
        [sr-de] URL der Benutzer Site Collection

    .Parameter Limit
        [sr-en] Specifies the maximum number of site collections to return
        [sr-de] Gibt die maximale Anzahl der zurückzugebenden Site Collections an
#>

param(            
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [int]$Limit = 500
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [string[]]$Properties = @('DisplayName','LoginName','IsSiteAdmin','IsGroup','Groups','UserType')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Site' = $Site
                            }      
                            
    if($PSCmdlet.ParameterSetName -eq 'All'){
        $cmdArgs.Add('Limit',$Limit)
    }
    
    $result = @()
    $null = Get-SPOUser @cmdArgs | Select-Object $Properties | Sort-Object DisplayName| ForEach-Object{
        $result += [PSCustomObject]@{
            DisplayName = $_.DisplayName
            LoginName = $_.LoginName
            IsSiteAdmin = $_.IsSiteAdmin
            IsGroup = $_.IsGroup
            Groups = ($_.Groups -join ';')
            UserType = $_.UserType
        }
    }
      
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