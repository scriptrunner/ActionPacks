#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Generates a report with the public or private Policies applied on your SharePoint Online Tenant
    
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

    .Parameter CdnType
        [sr-en] Specifies the CDN type
        [sr-de] CDN Typ
#>

param(            
    [Parameter(Mandatory = $true)]
    [ValidateSet('Public','Private')]
    [string]$CdnType
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [string[]]$Properties = @('Keys','Values','IsReadOnly','IsFixedSize','IsSynchronized','Count')
    
    $result = @()
    $null = Get-SPOTenantCdnPolicies -CdnType $CdnType -ErrorAction Stop | Select-Object $Properties | ForEach-Object{
        $result += [pscustomobject]@{
            Keys = ($_.Keys -join ';')
            Values = ($_.Values -join ';')
            IsReadOnly  = $_.IsReadOnly
            IsFixedSize = $_.IsFixedSize
            IsSynchronized = $_.IsSynchronized
            Count = $_.Count
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