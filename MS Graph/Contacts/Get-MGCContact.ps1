#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
    .SYNOPSIS
        Returns entities from contacts
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Contacts

    .Parameter ContactId
        [sr-en] Identifier of the contact
        [sr-de] Kontakt-ID

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$ContactId,
    [ValidateSet('DisplayName','Id','CompanyName','DeletedDateTime','Department','GivenName','Surname','Mail','MailNickname','JobTitle','MemberOf','OnPremisesLastSyncDateTime','ProxyAddresses')]
    [string[]]$Properties = @('DisplayName','Id','GivenName','Surname','Mail')
)          

Import-Module Microsoft.Graph.Identity.DirectoryManagement

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'}
    if($PSBoundParameters.ContainsKey('ContactId') -eq $true){
        $cmdArgs.Add('OrgContactId',$ContactId)
    }
    $result = Get-MgContact @cmdArgs | Sort-Object DisplayName | Select-Object $Properties

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