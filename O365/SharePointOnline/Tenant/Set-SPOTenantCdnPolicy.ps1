#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Sets the content delivery network (CDN) policies from the tenant level
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Tenant

    .Parameter CdnType
        Specifies the CDN type

    .Parameter PolicyType
        Specifies the policy type

    .Parameter PolicyValue
#>

param( 
    [Parameter(Mandatory = $true)]
    [ValidateSet('Public', 'Private')]
    [string]$CdnType,
    [Parameter(Mandatory = $true)]
    [ValidateSet('IncludeFileExtensions', 'ExcludeRestrictedSiteClassifications', 'ExcludeIfNoScriptDisabled')]
    [string]$PolicyType,
    [Parameter(Mandatory = $true)]
    [string]$PolicyValue
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    $result = Set-SPOTenantCdnPolicy -CdnType $CdnType -PolicyType $PolicyType `
                    -PolicyValue $PolicyValue -ErrorAction Stop | Select-Object *
      
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