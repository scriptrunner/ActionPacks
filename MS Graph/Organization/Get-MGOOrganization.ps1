#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
    .SYNOPSIS
        Returns a organization
    
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

    .Parameter Id
        [sr-en] Identifier of the organization
        [sr-de] ID der Organisation

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$Id,
    [ValidateSet('DisplayName','Id','BusinessPhones','City','PostalCode','Street','Country','CountryLetterCode','PreferredLanguage','CreatedDateTime','DeletedDateTime','OnPremisesLastSyncDateTime','OnPremisesSyncEnabled','State','TenantType')]
    [string[]]$Properties = @('DisplayName','Id','BusinessPhones','City','PostalCode','Street','Country','CreatedDateTime')
)

Import-Module Microsoft.Graph.Identity.DirectoryManagement

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'}
    if($PSBoundParameters.ContainsKey('Id') -eq $true){
        $cmdArgs.Add('OrganizationId',$Id)
    }
    else{
        $cmdArgs.Add('All',$null)
    }
    $result = Get-MgOrganization @cmdArgs | Select-Object $Properties

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