#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Generates a report with the groups on the specified site collection
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/_REPORTS_

    .Parameter Site
        [sr-en] Specifies the site collection scope
        [sr-de] Site Collection Bereich
        
    .Parameter Limit
        [sr-en] Specifies the maximum number of site collections to return
        [sr-de] Gibt die maximale Anzahl der zurückzugebenden Site Collections an
#>

param(            
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [int]$Limit = 200
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [string[]]$Properties = @('Title','LoginName','OwnerTitle','OwnerLoginName','Users','Roles')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Site' = $Site
                            'Limit' = $Limit
                            }      
    
    $result = 
    $result = @()
    $null = Get-SPOSiteGroup @cmdArgs | Select-Object $Properties | Sort-Object Title | ForEach-Object{
            $result += [pscustomobject]@{
                Title = $_.Title
                LoginName = $_.LoginName
                OwnerTitle  = $_.OwnerTitle
                OwnerLoginName = $_.OwnerLoginName
                Users = ($_.Users -join ';')
                Roles = ($_.Roles -join ';')
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